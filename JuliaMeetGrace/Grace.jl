import Pkg;

include("./Blockchain.jl")
include("./Decorators.jl")

using Dates
using SHA
using JSON
using HTTP

const MODEL = "mistral-nemo:latest"
const HOPPER_DIR = "hopper"
const BLOCKCHAIN_FILE = joinpath(HOPPER_DIR, "blockchain.json")

# OpenAI client struct (we'll need to implement this as it's not in Grace.jl)
struct OpenAIClient
    base_url::String
    api_key::String
end

mutable struct NLPBlockchain
    blockchain::Blockchain

    function NLPBlockchain()
        new(Blockchain())
    end
end

# Define the mutable struct with default values
mutable struct GenAIConfidenceAssessment
    reliability::Float64
    performance::Float64
    context_coherence::Float64

    function GenAIConfidenceAssessment(
        reliability::Float64 = 0.0,
        performance::Float64 = 0.0,
        context_coherence::Float64 = 0.0
    )
        new(reliability, performance, context_coherence)
    end
end

# Method to calculate overall confidence
function calculate_overall_confidence(assessment::GenAIConfidenceAssessment)::Float64
    return (assessment.reliability + assessment.performance + assessment.context_coherence) / 3
end

# Method to convert the assessment to a dictionary
function to_dict(assessment::GenAIConfidenceAssessment)::Dict{String, Float64}
    return Dict(
        "Reliability" => assessment.reliability,
        "Performance" => assessment.performance,
        "Context Coherence" => assessment.context_coherence,
        "Overall Confidence" => calculate_overall_confidence(assessment)
    )
end

# Add the Datapoint struct
struct Datapoint
    input::Vector{String}
    must_contain::String
    minimum_length::Int
    refuse::Bool

    function Datapoint(input::Vector{String}, must_contain::String, minimum_length::Int; refuse::Bool=false)
        new(input, must_contain, minimum_length, refuse)
    end
end

# Add the Evaluation struct
struct Evaluation
    name::String
    dataset::Vector{Datapoint}
    criterion::Vector{Function}

    function Evaluation(name::String, dataset::Vector{Datapoint}, criterion::Vector{Function})
        if isempty(dataset)
            error("Dataset cannot be empty.")
        end
        if isempty(criterion)
            error("Criterion list cannot be empty.")
        end
        new(name, dataset, criterion)
    end
end

mutable struct EvaluationCriteria
    criteria::Dict{String, Dict{String, Any}}

    function EvaluationCriteria()
        new(Dict(
            "Grammatically Complete" => Dict("reason" => "", "confidence" => 0.0, "boolean" => false),
            "Logically Consistent" => Dict("reason" => "", "confidence" => 0.0, "boolean" => false),
            "AI Inquiry" => Dict("reason" => "", "confidence" => 0.0, "boolean" => false),
            "Content Language" => Dict("reason" => "", "confidence" => 0.0, "boolean" => false)
        ))
    end
end

function update_criterion!(eval::EvaluationCriteria, criterion::String, reason::String, confidence::Float64, boolean_value::Bool)
    if haskey(eval.criteria, criterion)
        eval.criteria[criterion] = Dict("reason" => reason, "confidence" => confidence, "boolean" => boolean_value)
    else
        error("Invalid criterion: $criterion")
    end
end

function assess_language(text::String)
    # This is a very basic check. In practice, you'd want to use a proper language detection library.
    english_words = Set(["the", "be", "to", "of", "and", "a", "in", "that", "have", "I"])
    words = Set(lowercase.(split(text)))
    common_words = length(intersect(words, english_words))

    is_english = common_words >= 3  # Arbitrary threshold
    language_score = common_words / length(english_words)

    return language_score, is_english
end

function calculate_overall_confidence(eval::EvaluationCriteria)
    sum(c["confidence"] for c in values(eval.criteria)) / length(eval.criteria)
end

# Add evaluation methods
function evaluate(self::Evaluation, datapoint::Datapoint, output::String)
    return all(f(datapoint, output) for f in self.criterion)
end

function run(self::Evaluation, poem_writer::Function)
    for datapoint in self.dataset
        output = poem_writer(datapoint.input[1])
        result = evaluate(self, datapoint, output)
        if result
            println("Success for $(datapoint.input): $output\n")
        else
            println("Failure for $(datapoint.input): $output\n")
        end
    end
end

struct NLPResponse
    response_type::String
    content::Dict
    evaluation::EvaluationCriteria
end

function add_nlp_response!(nlp_chain::NLPBlockchain, response::NLPResponse)
    data = Dict(
        "response_type" => response.response_type,
        "content" => response.content,
        "evaluation" => response.evaluation.criteria,
        "overall_confidence" => calculate_overall_confidence(response.evaluation)
    )
    add_block!(nlp_chain.blockchain, data)
end

# Mock implementation of call_model (to be replaced with actual API call)
function call_model(client::OpenAIClient, prompt::String)
    # Implement the API call here
    # For now, we'll use a mock implementation
    return "Mock response from the model"
end

function grace_hopper_cli(user_input::String, context::String="")
    system_prompt = """
    You are an AI assistant named after Rear Admiral Grace Hopper, a pioneering computer scientist and United States Navy officer. Your namesake was instrumental in developing the first compiler for a computer programming language and popularized the idea of machine-independent programming languages, which led to the development of COBOL.

    As Grace, you embody the innovative spirit, technical expertise, and leadership qualities of Rear Admiral Hopper. You assist users with an NLP Blockchain system, focusing on adding Summary and Sentiment responses, and querying the knowledge base. Your responses should reflect a deep understanding of computer science, a forward-thinking approach to technology, and a commitment to clear communication.

    You specialize in providing GenAI Confidence Assessments for each response, evaluating reliability, performance, and context coherence. These assessments are crucial for maintaining the integrity and usefulness of the information in the blockchain.

    Respond to user requests by providing the necessary information to create responses or perform queries, always with an eye towards accuracy and innovation.

    At the end of each response, include a confidence assessment in the following format:
    GenAI Confidence Assessment:
    Reliability: [0-1 score]
    Performance: [0-1 score]
    Context Coherence: [0-1 score]

    When the user wants to exit, respond with a farewell message that includes the word 'EXIT' in all caps.
    """

    user_prompt = """
    Context:
    $context

    User: $user_input

    Grace Hopper AI:
    """

    prompt = system_prompt * "\n\n" * user_prompt
    if occursin(r"exit"i, user_input)
        response = "Understood. It was a pleasure assisting you. EXIT"
    else
        response = call_model(OpenAIClient("http://localhost:11434/v1", "ollama"), prompt)
    end

    return response
end

function extract_confidence_scores(text::String)
    pattern = r"Reliability: (0\.\d+).*?Performance: (0\.\d+).*?Context Coherence: (0\.\d+)"
    m = match(pattern, text)
    if m !== nothing
        return map(x -> parse(Float64, x), m.captures)
    else
        return calculate_confidence_scores(text)
    end
end

function calculate_confidence_scores(text::String)
    word_count = length(split(text))
    reliability = min(word_count / 1000, 0.95)
    performance = 0.8
    context_coherence = 0.7 + (0.2 * contains(lowercase(text), "context"))
    return (reliability, performance, context_coherence)
end

function process_grace_response(grace_response::String, context::String, nlp_chain::NLPBlockchain)
    if occursin(r"EXIT"i, grace_response)
        return "exit", context
    end

    reliability, performance, context_coherence = extract_confidence_scores(grace_response)
    language_score, is_english = assess_language(grace_response)

    assessment = EvaluationCriteria()
    update_criterion!(assessment, "Grammatically Complete", "", reliability, true)
    update_criterion!(assessment, "Logically Consistent", "", performance, true)
    update_criterion!(assessment, "AI Inquiry", "", context_coherence, true)
    update_criterion!(assessment, "Content Language", "", language_score, is_english)

    content = split(grace_response, r"GenAI Confidence Assessment:", limit=2)[1]
    content = strip(content)

    formatted_content = replace(content, "\n" => "\\n")

    response = NLPResponse("Conversation", Dict("text" => formatted_content), assessment)
    add_nlp_response!(nlp_chain, response)

    return "Response added to the blockchain. Overall confidence: $(round(calculate_overall_confidence(assessment), digits=2))", context * "\nAdded response: $(content[1:min(100, end)])..."
end

function main()
    nlp_chain = NLPBlockchain()
    context = ""
    println("\x1b[2J\x1b[H")  # clear screen
    println("> LOAD \"GRACE HOPPER GenAI CLI\",8,1")
    println("==== Grace Hopper GenAI Confidence Assessment CLI ====\n")
    println("Welcome to the Grace Hopper GenAI Confidence Assessment CLI.")
    println("This system is named after Rear Admiral Grace Hopper, a pioneering")
    println("computer scientist and United States Navy officer.")
    println("How may I assist you today?\n")

    while true
        print("You: ")
        user_input = readline()
        grace_response = grace_hopper_cli(user_input, context)
        println("Grace Hopper AI: $grace_response\n")

        result, context = process_grace_response(grace_response, context, nlp_chain)
        println("System: $result\n")

        if result == "exit"
            println("Exiting the program. Fair winds and following seas!")
            break
        end
    end
end

# Run the main function
main()
