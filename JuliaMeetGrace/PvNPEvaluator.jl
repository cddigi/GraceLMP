"""
PvNPEvaluator.jl - P vs NP Evaluation and Orchestration System

This module orchestrates the evaluation of NP-complete problems using
multiple GenAI agents with pre-scripted behaviors. It provides:
- Multi-agent orchestration
- Performance benchmarking
- Solution verification
- Blockchain integration for results
"""

module PvNPEvaluator

export ProblemInstance, EvaluationSession, SessionResult
export create_evaluation_session, run_evaluation, generate_report
export benchmark_problem, compare_agents, analyze_complexity

include("NPComplete.jl")
include("AgentSpawner.jl")
include("Blockchain.jl")

using .NPComplete
using .AgentSpawner
using Dates
using Statistics
using JSON
using UUIDs

# ============================================================================
# Problem Instance Wrapper
# ============================================================================

abstract type ProblemInstance end

struct SATProblemInstance <: ProblemInstance
    instance::NPComplete.SATInstance
    metadata::Dict{String, Any}
end

struct TSPProblemInstance <: ProblemInstance
    instance::NPComplete.TSPInstance
    metadata::Dict{String, Any}
end

struct GraphColoringProblemInstance <: ProblemInstance
    instance::NPComplete.GraphColoringInstance
    metadata::Dict{String, Any}
end

struct KnapsackProblemInstance <: ProblemInstance
    instance::NPComplete.KnapsackInstance
    metadata::Dict{String, Any}
end

# ============================================================================
# Evaluation Session
# ============================================================================

mutable struct EvaluationSession
    session_id::String
    problem::ProblemInstance
    agents::Vector{Agent}
    start_time::Float64
    results::Vector{Dict{String, Any}}
    blockchain::Blockchain

    function EvaluationSession(problem::ProblemInstance, agents::Vector{Agent})
        new(
            string(UUIDs.uuid4()),
            problem,
            agents,
            time(),
            Dict{String, Any}[],
            Blockchain()
        )
    end
end

struct SessionResult
    session_id::String
    problem_type::String
    problem_size::Int
    num_agents::Int
    total_time::Float64
    solutions_found::Int
    verified_solutions::Int
    agent_performances::Vector{Dict{String, Any}}
    complexity_analysis::Dict{String, Any}
    blockchain_hash::String
end

# ============================================================================
# Session Creation and Management
# ============================================================================

function create_evaluation_session(problem_type::String, size::Int,
                                   model_types::Vector{String}=["ollama"])::EvaluationSession
    problem = generate_problem_instance(problem_type, size)
    agents = create_agent_team(model_types)

    session = EvaluationSession(problem, agents)
    println("📊 Created evaluation session: $(session.session_id)")
    println("   Problem: $(problem_type) with size $(size)")
    println("   Agents: $(length(agents)) agents deployed")

    return session
end

function generate_problem_instance(problem_type::String, size::Int)::ProblemInstance
    metadata = Dict(
        "generated_at" => Dates.format(now(), "yyyy-mm-dd HH:MM:SS"),
        "size" => size,
        "type" => problem_type
    )

    if problem_type == "SAT"
        num_clauses = floor(Int, size * 4.3)  # Critical ratio for SAT
        instance = NPComplete.generate_random_sat(size, num_clauses, 3)
        return SATProblemInstance(instance, metadata)

    elseif problem_type == "TSP"
        instance = NPComplete.generate_random_tsp(size)
        return TSPProblemInstance(instance, metadata)

    elseif problem_type == "GraphColoring"
        instance = NPComplete.generate_random_graph(size, 0.3)
        return GraphColoringProblemInstance(instance, metadata)

    elseif problem_type == "Knapsack"
        weights = rand(1:100, size)
        values = rand(1:100, size)
        capacity = sum(weights) ÷ 2
        instance = NPComplete.KnapsackInstance(weights, values, capacity)
        return KnapsackProblemInstance(instance, metadata)

    else
        error("Unknown problem type: $problem_type")
    end
end

function create_agent_team(model_types::Vector{String})::Vector{Agent}
    agents = Agent[]

    for model_type in model_types
        model = create_model(model_type)

        push!(agents, create_solver_agent(model))
        push!(agents, create_verifier_agent(model))
        push!(agents, create_analyzer_agent(model))
    end

    return agents
end

function create_model(model_type::String)::GenAIModel
    if model_type == "claude"
        return ClaudeModel()
    elseif model_type == "gpt"
        return GPTModel()
    elseif model_type == "ollama"
        return OllamaModel()
    else
        return OllamaModel()
    end
end

# ============================================================================
# Problem-Specific Task Creation
# ============================================================================

function create_task_for_problem(problem::SATProblemInstance, role::AgentRole)::AgentTask
    description = """
    Boolean Satisfiability (SAT) Problem:
    - Number of variables: $(problem.instance.num_variables)
    - Number of clauses: $(length(problem.instance.clauses))
    - Problem name: $(problem.instance.name)

    This is an NP-complete problem. Find a satisfying assignment or prove none exists.
    """

    input_data = Dict{String, Any}(
        "num_variables" => problem.instance.num_variables,
        "num_clauses" => length(problem.instance.clauses),
        "difficulty" => "NP-Complete"
    )

    if role == SOLVER
        return AgentTask("SAT", description, input_data, "Boolean array",
                        ["Must satisfy all clauses", "Assignment length = num_variables"])
    elseif role == VERIFIER
        return AgentTask("SAT Verification", description, input_data, "Boolean",
                        ["Check all clauses satisfied"])
    else
        return AgentTask("SAT Analysis", description, input_data, "Text analysis",
                        ["Explain complexity", "Estimate runtime"])
    end
end

function create_task_for_problem(problem::TSPProblemInstance, role::AgentRole)::AgentTask
    description = """
    Traveling Salesman Problem (TSP):
    - Number of cities: $(problem.instance.num_cities)
    - Problem name: $(problem.instance.name)

    This is an NP-hard problem. Find the shortest tour visiting all cities exactly once.
    """

    input_data = Dict{String, Any}(
        "num_cities" => problem.instance.num_cities,
        "difficulty" => "NP-Hard"
    )

    if role == SOLVER
        return AgentTask("TSP", description, input_data, "Integer array (tour)",
                        ["Visit each city exactly once", "Return to start"])
    elseif role == VERIFIER
        return AgentTask("TSP Verification", description, input_data, "Boolean",
                        ["Verify valid tour", "Calculate total distance"])
    else
        return AgentTask("TSP Analysis", description, input_data, "Text analysis",
                        ["Explain complexity", "Compare algorithms"])
    end
end

function create_task_for_problem(problem::GraphColoringProblemInstance, role::AgentRole)::AgentTask
    description = """
    Graph Coloring Problem:
    - Number of vertices: $(problem.instance.num_vertices)
    - Number of edges: $(length(problem.instance.edges))
    - Available colors: $(problem.instance.num_colors)
    - Problem name: $(problem.instance.name)

    This is an NP-complete problem. Color vertices so no adjacent vertices share a color.
    """

    input_data = Dict{String, Any}(
        "num_vertices" => problem.instance.num_vertices,
        "num_edges" => length(problem.instance.edges),
        "num_colors" => problem.instance.num_colors,
        "difficulty" => "NP-Complete"
    )

    return AgentTask("Graph Coloring", description, input_data, "Integer array",
                    ["Use only available colors", "No adjacent vertices same color"])
end

function create_task_for_problem(problem::KnapsackProblemInstance, role::AgentRole)::AgentTask
    description = """
    Knapsack Problem:
    - Number of items: $(problem.instance.num_items)
    - Capacity: $(problem.instance.capacity)
    - Problem name: $(problem.instance.name)

    This is an NP-complete problem. Maximize value while staying within capacity.
    """

    input_data = Dict{String, Any}(
        "num_items" => problem.instance.num_items,
        "capacity" => problem.instance.capacity,
        "difficulty" => "NP-Complete"
    )

    return AgentTask("Knapsack", description, input_data, "Boolean array",
                    ["Total weight ≤ capacity", "Maximize total value"])
end

# ============================================================================
# Evaluation Execution
# ============================================================================

function run_evaluation(session::EvaluationSession; timeout::Float64=60.0)::SessionResult
    println("\n🚀 Starting evaluation session: $(session.session_id)")
    println("=" ^ 70)

    results = Dict{String, Any}[]

    for agent in session.agents
        println("\n🤖 Executing agent: $(agent.id) ($(agent.role))")

        task = create_task_for_problem(session.problem, agent.role)

        try
            result = execute_agent_task(agent, task)
            push!(results, result)

            add_block!(session.blockchain, Dict{String, Any}(
                "type" => "agent_result",
                "agent_id" => agent.id,
                "agent_role" => string(agent.role),
                "execution_time" => result["execution_time"],
                "timestamp" => result["timestamp"]
            ))

            println("   ✓ Completed in $(round(result["execution_time"], digits=3))s")
            println("   Response preview: $(first(result["response"], 100))...")

        catch e
            println("   ✗ Error: $e")
            push!(results, Dict{String, Any}(
                "agent_id" => agent.id,
                "error" => string(e)
            ))
        end
    end

    session.results = results
    total_time = time() - session.start_time

    println("\n" * "=" ^ 70)
    println("✅ Evaluation session completed in $(round(total_time, digits=2))s")

    return create_session_result(session, total_time)
end

function create_session_result(session::EvaluationSession, total_time::Float64)::SessionResult
    problem_type = get_problem_type(session.problem)
    problem_size = get_problem_size(session.problem)

    complexity_analysis = NPComplete.get_problem_complexity(problem_type, problem_size)

    agent_performances = [
        evaluate_agent_performance(agent) for agent in session.agents
    ]

    return SessionResult(
        session.session_id,
        problem_type,
        problem_size,
        length(session.agents),
        total_time,
        length(session.results),
        0,  # Will be filled by verification
        agent_performances,
        complexity_analysis,
        get_latest_block(session.blockchain).hash
    )
end

# ============================================================================
# Utility Functions
# ============================================================================

function get_problem_type(problem::ProblemInstance)::String
    if problem isa SATProblemInstance
        return "SAT"
    elseif problem isa TSPProblemInstance
        return "TSP"
    elseif problem isa GraphColoringProblemInstance
        return "GraphColoring"
    elseif problem isa KnapsackProblemInstance
        return "Knapsack"
    else
        return "Unknown"
    end
end

function get_problem_size(problem::ProblemInstance)::Int
    if problem isa SATProblemInstance
        return problem.instance.num_variables
    elseif problem isa TSPProblemInstance
        return problem.instance.num_cities
    elseif problem isa GraphColoringProblemInstance
        return problem.instance.num_vertices
    elseif problem isa KnapsackProblemInstance
        return problem.instance.num_items
    else
        return 0
    end
end

# ============================================================================
# Benchmarking and Analysis
# ============================================================================

function benchmark_problem(problem_type::String, sizes::Vector{Int})::Dict{String, Any}
    results = Dict{String, Any}()

    for size in sizes
        println("\n📏 Benchmarking $(problem_type) with size $(size)")

        complexity = NPComplete.get_problem_complexity(problem_type, size)
        runtime_estimate = NPComplete.estimate_runtime(
            get(complexity, "estimated_ops", 0)
        )

        results[string(size)] = Dict(
            "complexity" => complexity,
            "estimated_runtime" => runtime_estimate
        )

        println("   Time complexity: $(complexity["time_complexity"])")
        println("   Estimated runtime: $(runtime_estimate)")
    end

    return results
end

function compare_agents(session::EvaluationSession)::Dict{String, Any}
    comparisons = Dict{String, Any}()

    for agent in session.agents
        perf = evaluate_agent_performance(agent)
        comparisons[agent.id] = perf
    end

    return comparisons
end

function analyze_complexity(problem_type::String, size::Int)::Dict{String, Any}
    complexity = NPComplete.get_problem_complexity(problem_type, size)

    analysis = Dict{String, Any}(
        "problem_type" => problem_type,
        "size" => size,
        "complexity_class" => complexity["problem_class"],
        "time_complexity" => complexity["time_complexity"],
        "space_complexity" => complexity["space_complexity"],
        "estimated_operations" => complexity["estimated_ops"],
        "estimated_runtime" => NPComplete.estimate_runtime(complexity["estimated_ops"]),
        "tractability" => complexity["estimated_ops"] < 1e9 ? "Tractable" : "Intractable"
    )

    return analysis
end

# ============================================================================
# Report Generation
# ============================================================================

function generate_report(result::SessionResult)::String
    report = """
    ╔════════════════════════════════════════════════════════════════════════╗
    ║              P vs NP EVALUATION SESSION REPORT                         ║
    ╚════════════════════════════════════════════════════════════════════════╝

    SESSION INFORMATION:
    ├─ Session ID: $(result.session_id)
    ├─ Problem Type: $(result.problem_type)
    ├─ Problem Size: $(result.problem_size)
    ├─ Number of Agents: $(result.num_agents)
    └─ Total Execution Time: $(round(result.total_time, digits=3))s

    COMPLEXITY ANALYSIS:
    ├─ Complexity Class: $(result.complexity_analysis["problem_class"])
    ├─ Time Complexity: $(result.complexity_analysis["time_complexity"])
    ├─ Space Complexity: $(result.complexity_analysis["space_complexity"])
    ├─ Estimated Operations: $(result.complexity_analysis["estimated_ops"])
    └─ Estimated Runtime: $(NPComplete.estimate_runtime(result.complexity_analysis["estimated_ops"]))

    AGENT PERFORMANCE:
    """

    for (i, perf) in enumerate(result.agent_performances)
        report *= """
        Agent $(i):
        ├─ Role: $(perf["agent_role"])
        ├─ Model: $(perf["model_type"])
        ├─ Tasks Completed: $(perf["total_tasks"])
        └─ Avg Execution Time: $(round(perf["average_execution_time"], digits=3))s

        """
    end

    report *= """
    BLOCKCHAIN VERIFICATION:
    └─ Latest Block Hash: $(result.blockchain_hash)

    ╔════════════════════════════════════════════════════════════════════════╗
    ║                         END OF REPORT                                  ║
    ╚════════════════════════════════════════════════════════════════════════╝
    """

    return report
end

end # module PvNPEvaluator
