"""
Test Suite for P vs NP Evaluation System

This file contains basic tests to verify the system works correctly.
Run with: julia test_pvnp.jl
"""

println("Testing P vs NP Evaluation System")
println("=" ^ 70)

# Test 1: Load modules
println("\n[Test 1] Loading modules...")
try
    include("NPComplete.jl")
    using .NPComplete
    println("✅ NPComplete module loaded successfully")
catch e
    println("❌ Failed to load NPComplete: $e")
    exit(1)
end

try
    include("AgentSpawner.jl")
    using .AgentSpawner
    println("✅ AgentSpawner module loaded successfully")
catch e
    println("❌ Failed to load AgentSpawner: $e")
    exit(1)
end

try
    include("PvNPEvaluator.jl")
    using .PvNPEvaluator
    println("✅ PvNPEvaluator module loaded successfully")
catch e
    println("❌ Failed to load PvNPEvaluator: $e")
    exit(1)
end

# Test 2: Generate SAT instance
println("\n[Test 2] Generating SAT problem instance...")
try
    sat = NPComplete.generate_random_sat(5, 10, 3)
    println("✅ Generated SAT with $(sat.num_variables) variables and $(length(sat.clauses)) clauses")
catch e
    println("❌ Failed to generate SAT: $e")
end

# Test 3: Solve small SAT
println("\n[Test 3] Solving small SAT instance...")
try
    sat = NPComplete.generate_random_sat(4, 8, 3)
    solution = NPComplete.solve_sat_bruteforce(sat)
    if solution !== nothing
        is_valid = NPComplete.verify_sat_solution(sat, solution)
        if is_valid
            println("✅ Found and verified SAT solution: $solution")
        else
            println("❌ Solution found but verification failed")
        end
    else
        println("⚠️  No solution exists for this SAT instance")
    end
catch e
    println("❌ Failed to solve SAT: $e")
end

# Test 4: Generate and solve TSP
println("\n[Test 4] Generating and solving TSP...")
try
    tsp = NPComplete.generate_random_tsp(4)
    tour, distance = NPComplete.solve_tsp_bruteforce(tsp)
    println("✅ TSP solved - Best tour: $tour, Distance: $(round(distance, digits=2))")
catch e
    println("❌ Failed with TSP: $e")
end

# Test 5: Graph Coloring
println("\n[Test 5] Testing Graph Coloring...")
try
    graph = NPComplete.generate_random_graph(6, 0.3)
    println("✅ Generated graph with $(graph.num_vertices) vertices and $(length(graph.edges)) edges")
catch e
    println("❌ Failed to generate graph: $e")
end

# Test 6: Knapsack
println("\n[Test 6] Testing Knapsack problem...")
try
    weights = [2, 3, 4, 5]
    values = [3, 4, 5, 6]
    capacity = 8
    knapsack = NPComplete.KnapsackInstance(weights, values, capacity)
    selection, value = NPComplete.solve_knapsack_bruteforce(knapsack)
    println("✅ Knapsack solved - Value: $value, Selection: $selection")
catch e
    println("❌ Failed with Knapsack: $e")
end

# Test 7: Complexity Analysis
println("\n[Test 7] Testing complexity analysis...")
try
    complexity = NPComplete.get_problem_complexity("SAT", 10)
    println("✅ SAT complexity: $(complexity["time_complexity"]), Class: $(complexity["problem_class"])")

    runtime = NPComplete.estimate_runtime(1000000)
    println("✅ Runtime estimation: $runtime")
catch e
    println("❌ Failed complexity analysis: $e")
end

# Test 8: Agent Creation
println("\n[Test 8] Creating agents...")
try
    model = AgentSpawner.OllamaModel()
    agent = AgentSpawner.create_solver_agent(model)
    println("✅ Created solver agent with ID: $(agent.id)")

    verifier = AgentSpawner.create_verifier_agent(model)
    println("✅ Created verifier agent with ID: $(verifier.id)")

    analyzer = AgentSpawner.create_analyzer_agent(model)
    println("✅ Created analyzer agent with ID: $(analyzer.id)")
catch e
    println("❌ Failed to create agents: $e")
end

# Test 9: Agent Task Creation
println("\n[Test 9] Creating agent task...")
try
    task = AgentSpawner.AgentTask(
        "SAT",
        "Test SAT problem",
        Dict{String, Any}("num_variables" => 5),
        "Boolean array",
        ["Must satisfy all clauses"]
    )
    println("✅ Created task: $(task.problem_type)")
catch e
    println("❌ Failed to create task: $e")
end

# Test 10: Problem Instance Wrapper
println("\n[Test 10] Testing problem instance wrapper...")
try
    session = PvNPEvaluator.create_evaluation_session("SAT", 5, ["ollama"])
    println("✅ Created evaluation session: $(session.session_id)")
    println("   Problem type: $(PvNPEvaluator.get_problem_type(session.problem))")
    println("   Problem size: $(PvNPEvaluator.get_problem_size(session.problem))")
catch e
    println("❌ Failed to create session: $e")
end

# Test 11: Complexity Analysis via Evaluator
println("\n[Test 11] Testing evaluator complexity analysis...")
try
    analysis = PvNPEvaluator.analyze_complexity("TSP", 8)
    println("✅ Complexity analysis:")
    println("   Problem: $(analysis["problem_type"])")
    println("   Size: $(analysis["size"])")
    println("   Class: $(analysis["complexity_class"])")
    println("   Time: $(analysis["time_complexity"])")
    println("   Tractability: $(analysis["tractability"])")
catch e
    println("❌ Failed complexity analysis: $e")
end

# Test 12: Benchmarking
println("\n[Test 12] Testing benchmark functionality...")
try
    results = PvNPEvaluator.benchmark_problem("SAT", [4, 6, 8])
    println("✅ Benchmark completed for $(length(results)) problem sizes")
catch e
    println("❌ Failed benchmark: $e")
end

println("\n" * "=" ^ 70)
println("🎉 Test suite completed!")
println("\nNote: Full evaluation tests require Ollama or API keys.")
println("To run a full evaluation, use:")
println("  julia PvNP.jl --problem SAT --size 6")
