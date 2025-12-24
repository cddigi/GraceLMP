"""
AgentSpawner.jl - Agent Task Definitions for Claude Code Sub-Agents

This module defines agent roles and tasks for P vs NP problem solving evaluation.
Agent tasks are designed to be executed by Claude Code's sub-agent system.

See: https://docs.anthropic.com/en/docs/claude-code/sub-agents
"""

module AgentSpawner

export AgentRole, AgentTask, Agent
export spawn_agent, execute_agent_task, evaluate_agent_performance
export create_solver_agent, create_verifier_agent, create_analyzer_agent
export get_default_prompt, format_task_for_subagent

using JSON
using UUIDs

# ============================================================================
# Agent Role Definitions
# ============================================================================

@enum AgentRole begin
    SOLVER      # Attempts to solve the problem
    VERIFIER    # Verifies solutions
    ANALYZER    # Analyzes complexity and performance
    OPTIMIZER   # Suggests optimizations
    RESEARCHER  # Researches problem approaches
end

# ============================================================================
# Agent Task Structure
# ============================================================================

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

# ============================================================================
# Agent Structure (Lightweight - no external API dependencies)
# ============================================================================

mutable struct Agent
    id::String
    role::AgentRole
    system_prompt::String
    task_history::Vector{Dict{String, Any}}
    performance_metrics::Dict{String, Float64}
    created_at::Float64

    function Agent(role::AgentRole, custom_prompt::String="")
        id = string(UUIDs.uuid4())
        system_prompt = custom_prompt != "" ? custom_prompt : get_default_prompt(role)
        new(id, role, system_prompt, Dict{String, Any}[],
            Dict{String, Float64}(), time())
    end
end

# ============================================================================
# Pre-scripted Agent Behavior Prompts
# These prompts define what each agent role should do when spawned as a
# Claude Code sub-agent using the Task tool.
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

function create_solver_agent()::Agent
    return Agent(SOLVER)
end

function create_verifier_agent()::Agent
    return Agent(VERIFIER)
end

function create_analyzer_agent()::Agent
    return Agent(ANALYZER)
end

# ============================================================================
# Agent Spawning
# ============================================================================

function spawn_agent(role::AgentRole, task::AgentTask)::Agent
    agent = Agent(role)
    println("🤖 Spawned $(role) agent with ID: $(agent.id)")
    return agent
end

# ============================================================================
# Format Task for Claude Code Sub-Agent
# This creates a structured prompt suitable for Claude Code's Task tool
# ============================================================================

function format_task_for_subagent(agent::Agent, task::AgentTask)::String
    return """
    ## Agent Role: $(agent.role)

    $(agent.system_prompt)

    ## Task: $(task.problem_type)

    ### Problem Description
    $(task.problem_description)

    ### Input Data
    $(JSON.json(task.input_data, 2))

    ### Expected Output Format
    $(task.expected_output_format)

    ### Constraints
    $(join(["- " * c for c in task.constraints], "\n"))

    Please provide your analysis and response.
    """
end

# ============================================================================
# Execute Agent Task
# Returns structured data about the task for Claude Code to process
# ============================================================================

function execute_agent_task(agent::Agent, task::AgentTask)::Dict{String, Any}
    start_time = time()

    # Format the task prompt for sub-agent execution
    subagent_prompt = format_task_for_subagent(agent, task)

    # Generate a deterministic response based on the problem type and role
    # This provides immediate feedback while Claude Code can spawn actual sub-agents
    response = generate_analysis_response(agent.role, task)

    execution_time = time() - start_time
    agent.performance_metrics["last_execution_time"] = execution_time

    task_record = Dict(
        "agent_id" => agent.id,
        "agent_role" => string(agent.role),
        "task_type" => task.problem_type,
        "subagent_prompt" => subagent_prompt,
        "response" => response,
        "execution_time" => execution_time,
        "timestamp" => time()
    )

    push!(agent.task_history, task_record)

    return task_record
end

# ============================================================================
# Generate Analysis Response
# Provides algorithmic analysis based on problem type and agent role
# ============================================================================

function generate_analysis_response(role::AgentRole, task::AgentTask)::String
    problem = task.problem_type
    data = task.input_data

    if role == SOLVER
        return generate_solver_response(problem, data)
    elseif role == VERIFIER
        return generate_verifier_response(problem, data)
    elseif role == ANALYZER
        return generate_analyzer_response(problem, data)
    elseif role == OPTIMIZER
        return generate_optimizer_response(problem, data)
    else
        return generate_researcher_response(problem, data)
    end
end

function generate_solver_response(problem::String, data::Dict{String, Any})::String
    if occursin("SAT", problem)
        n = get(data, "num_variables", 0)
        return """
        SAT Solver Analysis:
        • Problem size: $(n) variables
        • Search space: 2^$(n) = $(2^min(n, 30)) combinations
        • Approach: Systematic enumeration with early termination
        • Strategy: Try assignments in lexicographic order, prune on conflict
        • Expected: Solution exists if clause density < 4.27 (phase transition)
        """
    elseif occursin("TSP", problem)
        n = get(data, "num_cities", 0)
        return """
        TSP Solver Analysis:
        • Problem size: $(n) cities
        • Search space: $(n)! = $(factorial(min(n, 12))) permutations
        • Approach: Branch and bound with nearest neighbor heuristic
        • Strategy: Start with greedy tour, improve with 2-opt swaps
        • Expected: Optimal for n ≤ 12, heuristic for larger
        """
    else
        return "Solver initialized for $(problem). Ready to find solution."
    end
end

function generate_verifier_response(problem::String, data::Dict{String, Any})::String
    return """
    Verification Protocol for $(problem):
    • Constraint checking: All problem constraints will be validated
    • Solution format: Verified against expected output format
    • Correctness: Mathematical proof of solution validity
    • Status: Ready to verify any proposed solution
    """
end

function generate_analyzer_response(problem::String, data::Dict{String, Any})::String
    complexity = get(data, "difficulty", "NP-Complete")
    return """
    Complexity Analysis for $(problem):
    • Classification: $(complexity)
    • Time complexity: Exponential in worst case
    • Space complexity: Polynomial (linear for most representations)
    • Practical implications: Exact solutions feasible for small instances only
    • Recommendation: Use heuristics or approximation for large instances
    """
end

function generate_optimizer_response(problem::String, data::Dict{String, Any})::String
    return """
    Optimization Recommendations for $(problem):
    • Pruning: Early termination on constraint violation
    • Heuristics: Problem-specific ordering of search choices
    • Caching: Memoize subproblem solutions where applicable
    • Parallelization: Distribute search across multiple threads
    • Approximation: Consider relaxed solutions with quality bounds
    """
end

function generate_researcher_response(problem::String, data::Dict{String, Any})::String
    return """
    Research Context for $(problem):
    • Historical: Part of Karp's 21 NP-complete problems (1972)
    • Theoretical: Reducible to/from other NP-complete problems
    • Open questions: P vs NP remains unsolved (Millennium Prize Problem)
    • Practical impact: Cryptography, optimization, AI planning
    • Current research: Quantum algorithms, parameterized complexity
    """
end

# ============================================================================
# Performance Evaluation
# ============================================================================

function evaluate_agent_performance(agent::Agent)::Dict{String, Any}
    return Dict(
        "agent_id" => agent.id,
        "agent_role" => string(agent.role),
        "total_tasks" => length(agent.task_history),
        "average_execution_time" => get(agent.performance_metrics, "last_execution_time", 0.0),
        "uptime" => time() - agent.created_at
    )
end

end # module AgentSpawner
