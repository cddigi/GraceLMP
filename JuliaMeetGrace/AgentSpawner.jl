"""
AgentSpawner.jl - GenAI Model Integration for Agent Spawning

This module provides integration with various GenAI models to spawn
pre-scripted agents for P vs NP problem solving evaluation.

Supported Models:
- Claude (Anthropic)
- GPT (OpenAI)
- Ollama (Local models)
- Custom agents
"""

module AgentSpawner

export GenAIModel, Agent, AgentRole, AgentTask
export spawn_agent, execute_agent_task, evaluate_agent_performance
export ClaudeModel, GPTModel, OllamaModel
export create_solver_agent, create_verifier_agent, create_analyzer_agent

using HTTP
using JSON
using UUIDs

# ============================================================================
# Model Definitions
# ============================================================================

abstract type GenAIModel end

struct ClaudeModel <: GenAIModel
    api_key::String
    model_name::String
    base_url::String

    function ClaudeModel(api_key::String="", model_name::String="claude-sonnet-4-5-20250929")
        new(api_key, model_name, "https://api.anthropic.com/v1/messages")
    end
end

struct GPTModel <: GenAIModel
    api_key::String
    model_name::String
    base_url::String

    function GPTModel(api_key::String="", model_name::String="gpt-4")
        new(api_key, model_name, "https://api.openai.com/v1/chat/completions")
    end
end

struct OllamaModel <: GenAIModel
    model_name::String
    base_url::String

    function OllamaModel(model_name::String="mistral-nemo:latest",
                        base_url::String="http://localhost:11434")
        new(model_name, base_url)
    end
end

# ============================================================================
# Agent Definitions
# ============================================================================

@enum AgentRole begin
    SOLVER      # Attempts to solve the problem
    VERIFIER    # Verifies solutions
    ANALYZER    # Analyzes complexity and performance
    OPTIMIZER   # Suggests optimizations
    RESEARCHER  # Researches problem approaches
end

struct AgentTask
    problem_type::String
    problem_description::String
    input_data::Dict{String, Any}
    expected_output_format::String
    constraints::Vector{String}

    function AgentTask(problem_type::String, problem_description::String,
                      input_data::Dict{String, Any}=Dict{String, Any}(),
                      expected_output_format::String="JSON",
                      constraints::Vector{String}=String[])
        new(problem_type, problem_description, input_data,
            expected_output_format, constraints)
    end
end

mutable struct Agent
    id::String
    role::AgentRole
    model::GenAIModel
    system_prompt::String
    conversation_history::Vector{Dict{String, String}}
    performance_metrics::Dict{String, Float64}
    created_at::Float64

    function Agent(role::AgentRole, model::GenAIModel, custom_prompt::String="")
        id = string(UUIDs.uuid4())
        system_prompt = custom_prompt != "" ? custom_prompt : get_default_prompt(role)
        new(id, role, model, system_prompt, Dict{String, String}[],
            Dict{String, Float64}(), time())
    end
end

# ============================================================================
# Pre-scripted Agent Behaviors
# ============================================================================

function get_default_prompt(role::AgentRole)::String
    prompts = Dict(
        SOLVER => """
        You are an expert algorithm solver specializing in NP-complete problems.
        Your task is to analyze the given problem instance and attempt to find
        an optimal or near-optimal solution. You should:

        1. Understand the problem structure
        2. Apply appropriate algorithmic techniques
        3. Provide a clear solution with justification
        4. Estimate the solution quality

        Focus on correctness first, then optimization.
        """,

        VERIFIER => """
        You are a rigorous solution verifier for computational problems.
        Your task is to verify whether proposed solutions are correct.
        You should:

        1. Check all constraints are satisfied
        2. Validate the solution format
        3. Verify computational correctness
        4. Report any violations or errors

        Be thorough and precise in your verification.
        """,

        ANALYZER => """
        You are a computational complexity analyst.
        Your task is to analyze algorithms and their performance.
        You should:

        1. Identify the computational complexity class
        2. Estimate time and space requirements
        3. Compare different algorithmic approaches
        4. Provide insights on scalability

        Focus on rigorous complexity analysis.
        """,

        OPTIMIZER => """
        You are an algorithm optimization expert.
        Your task is to suggest improvements to problem-solving approaches.
        You should:

        1. Identify bottlenecks in current solutions
        2. Suggest algorithmic optimizations
        3. Propose heuristics or approximations
        4. Estimate improvement potential

        Balance between theoretical optimality and practical efficiency.
        """,

        RESEARCHER => """
        You are a computer science researcher specializing in P vs NP problems.
        Your task is to research and explain problem-solving approaches.
        You should:

        1. Explain the theoretical background
        2. Survey known algorithms and techniques
        3. Discuss open problems and challenges
        4. Provide references to relevant literature

        Maintain academic rigor and clarity.
        """
    )

    return get(prompts, role, "You are a helpful AI assistant.")
end

# ============================================================================
# Agent Creation Functions
# ============================================================================

function create_solver_agent(model::GenAIModel=OllamaModel())::Agent
    return Agent(SOLVER, model)
end

function create_verifier_agent(model::GenAIModel=OllamaModel())::Agent
    return Agent(VERIFIER, model)
end

function create_analyzer_agent(model::GenAIModel=OllamaModel())::Agent
    return Agent(ANALYZER, model)
end

# ============================================================================
# Agent Spawning and Execution
# ============================================================================

function spawn_agent(role::AgentRole, model::GenAIModel, task::AgentTask)::Agent
    agent = Agent(role, model)
    println("🤖 Spawned $(role) agent with ID: $(agent.id)")
    return agent
end

function call_claude_api(model::ClaudeModel, messages::Vector{Dict{String, String}},
                        system_prompt::String)::String
    if model.api_key == ""
        return mock_claude_response(messages[end]["content"])
    end

    headers = Dict(
        "x-api-key" => model.api_key,
        "anthropic-version" => "2023-06-01",
        "content-type" => "application/json"
    )

    body = Dict(
        "model" => model.model_name,
        "max_tokens" => 4096,
        "system" => system_prompt,
        "messages" => messages
    )

    try
        response = HTTP.post(model.base_url, headers, JSON.json(body))
        result = JSON.parse(String(response.body))
        return result["content"][1]["text"]
    catch e
        println("⚠️  Error calling Claude API: $e")
        return mock_claude_response(messages[end]["content"])
    end
end

function call_gpt_api(model::GPTModel, messages::Vector{Dict{String, String}},
                     system_prompt::String)::String
    if model.api_key == ""
        return mock_gpt_response(messages[end]["content"])
    end

    headers = Dict(
        "Authorization" => "Bearer $(model.api_key)",
        "Content-Type" => "application/json"
    )

    all_messages = [Dict("role" => "system", "content" => system_prompt)]
    append!(all_messages, messages)

    body = Dict(
        "model" => model.model_name,
        "messages" => all_messages,
        "temperature" => 0.7
    )

    try
        response = HTTP.post(model.base_url, headers, JSON.json(body))
        result = JSON.parse(String(response.body))
        return result["choices"][1]["message"]["content"]
    catch e
        println("⚠️  Error calling GPT API: $e")
        return mock_gpt_response(messages[end]["content"])
    end
end

function call_ollama_api(model::OllamaModel, messages::Vector{Dict{String, String}},
                        system_prompt::String)::String
    url = "$(model.base_url)/api/chat"

    all_messages = [Dict("role" => "system", "content" => system_prompt)]
    append!(all_messages, messages)

    body = Dict(
        "model" => model.model_name,
        "messages" => all_messages,
        "stream" => false
    )

    try
        response = HTTP.post(url, ["Content-Type" => "application/json"], JSON.json(body))
        result = JSON.parse(String(response.body))
        return result["message"]["content"]
    catch e
        println("⚠️  Error calling Ollama API: $e")
        return mock_ollama_response(messages[end]["content"])
    end
end

function call_model(model::GenAIModel, messages::Vector{Dict{String, String}},
                   system_prompt::String)::String
    if model isa ClaudeModel
        return call_claude_api(model, messages, system_prompt)
    elseif model isa GPTModel
        return call_gpt_api(model, messages, system_prompt)
    elseif model isa OllamaModel
        return call_ollama_api(model, messages, system_prompt)
    else
        error("Unsupported model type")
    end
end

function execute_agent_task(agent::Agent, task::AgentTask)::Dict{String, Any}
    start_time = time()

    task_prompt = """
    Task: $(task.problem_type)

    Problem Description:
    $(task.problem_description)

    Input Data:
    $(JSON.json(task.input_data, 2))

    Expected Output Format: $(task.expected_output_format)

    Constraints:
    $(join(task.constraints, "\n"))

    Please provide your $(agent.role) analysis and response.
    """

    message = Dict("role" => "user", "content" => task_prompt)
    push!(agent.conversation_history, message)

    response = call_model(agent.model, agent.conversation_history, agent.system_prompt)

    assistant_message = Dict("role" => "assistant", "content" => response)
    push!(agent.conversation_history, assistant_message)

    execution_time = time() - start_time
    agent.performance_metrics["last_execution_time"] = execution_time

    return Dict(
        "agent_id" => agent.id,
        "agent_role" => string(agent.role),
        "task_type" => task.problem_type,
        "response" => response,
        "execution_time" => execution_time,
        "timestamp" => time()
    )
end

# ============================================================================
# Mock Responses (for testing without API keys)
# ============================================================================

function mock_claude_response(prompt::String)::String
    if occursin("SAT", prompt)
        return "Based on the SAT instance provided, I'll attempt to find a satisfying assignment using systematic exploration of the solution space."
    elseif occursin("TSP", prompt)
        return "For this Traveling Salesman Problem, I'll apply a greedy nearest-neighbor heuristic followed by 2-opt improvements."
    else
        return "I've analyzed the problem instance. For NP-complete problems of this size, exact solutions require exponential time."
    end
end

function mock_gpt_response(prompt::String)::String
    return "Analysis complete. The problem exhibits characteristics typical of NP-complete complexity class."
end

function mock_ollama_response(prompt::String)::String
    return "I've processed the task. The algorithmic approach should consider both correctness and computational efficiency."
end

# ============================================================================
# Performance Evaluation
# ============================================================================

function evaluate_agent_performance(agent::Agent)::Dict{String, Any}
    return Dict(
        "agent_id" => agent.id,
        "agent_role" => string(agent.role),
        "model_type" => string(typeof(agent.model)),
        "total_tasks" => length(agent.conversation_history) ÷ 2,
        "average_execution_time" => get(agent.performance_metrics, "last_execution_time", 0.0),
        "uptime" => time() - agent.created_at
    )
end

end # module AgentSpawner
