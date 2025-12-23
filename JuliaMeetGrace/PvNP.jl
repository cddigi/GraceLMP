#!/usr/bin/env julia
"""
PvNP.jl - Main Program for P vs NP Evaluation using GenAI Agents

This program evaluates NP-complete problems using multiple GenAI models
to spawn pre-scripted agents. It focuses on finding and analyzing
NP-complete algorithms through automated agent-based evaluation.

Usage:
    julia PvNP.jl [options]

Options:
    --problem <type>     Problem type: SAT, TSP, GraphColoring, Knapsack (default: SAT)
    --size <n>          Problem size (default: 10)
    --models <models>   Comma-separated list of models: ollama,claude,gpt (default: ollama)
    --benchmark         Run benchmark mode
    --interactive       Run interactive mode
    --help             Show this help message

Examples:
    julia PvNP.jl --problem SAT --size 8
    julia PvNP.jl --problem TSP --size 6 --models ollama,claude
    julia PvNP.jl --benchmark
    julia PvNP.jl --interactive
"""

include("PvNPEvaluator.jl")

using .PvNPEvaluator
using .NPComplete
using .AgentSpawner

# ============================================================================
# Command Line Interface
# ============================================================================

function parse_arguments(args::Vector{String})::Dict{String, Any}
    options = Dict{String, Any}(
        "problem" => "SAT",
        "size" => 10,
        "models" => ["ollama"],
        "benchmark" => false,
        "interactive" => false,
        "help" => false
    )

    i = 1
    while i <= length(args)
        arg = args[i]

        if arg == "--help" || arg == "-h"
            options["help"] = true
        elseif arg == "--problem" && i < length(args)
            options["problem"] = args[i + 1]
            i += 1
        elseif arg == "--size" && i < length(args)
            options["size"] = parse(Int, args[i + 1])
            i += 1
        elseif arg == "--models" && i < length(args)
            options["models"] = split(args[i + 1], ',')
            i += 1
        elseif arg == "--benchmark"
            options["benchmark"] = true
        elseif arg == "--interactive"
            options["interactive"] = true
        end

        i += 1
    end

    return options
end

function show_help()
    println(__doc__)
end

# ============================================================================
# Interactive Mode
# ============================================================================

function interactive_mode()
    println("\x1b[2J\x1b[H")  # Clear screen
    println("╔════════════════════════════════════════════════════════════════════════╗")
    println("║          P vs NP Evaluation System - Interactive Mode                 ║")
    println("║          Using GenAI Agents for NP-Complete Problem Analysis          ║")
    println("╚════════════════════════════════════════════════════════════════════════╝")
    println()

    while true
        println("\nAvailable Commands:")
        println("  1. Evaluate SAT problem")
        println("  2. Evaluate TSP problem")
        println("  3. Evaluate Graph Coloring problem")
        println("  4. Evaluate Knapsack problem")
        println("  5. Run benchmark")
        println("  6. Analyze complexity")
        println("  7. Exit")
        print("\nEnter your choice (1-7): ")

        choice = readline()

        if choice == "1"
            run_interactive_evaluation("SAT")
        elseif choice == "2"
            run_interactive_evaluation("TSP")
        elseif choice == "3"
            run_interactive_evaluation("GraphColoring")
        elseif choice == "4"
            run_interactive_evaluation("Knapsack")
        elseif choice == "5"
            run_interactive_benchmark()
        elseif choice == "6"
            run_interactive_complexity_analysis()
        elseif choice == "7"
            println("\n👋 Exiting P vs NP Evaluation System. Goodbye!")
            break
        else
            println("❌ Invalid choice. Please try again.")
        end
    end
end

function run_interactive_evaluation(problem_type::String)
    print("Enter problem size (default 10): ")
    size_input = readline()
    size = isempty(size_input) ? 10 : parse(Int, size_input)

    print("Enter models (ollama/claude/gpt, comma-separated, default ollama): ")
    models_input = readline()
    models = isempty(models_input) ? ["ollama"] : split(models_input, ',')

    println("\n🔬 Creating evaluation session...")
    session = create_evaluation_session(problem_type, size, models)

    println("\n⚙️  Running evaluation...")
    result = run_evaluation(session)

    println("\n📊 Generating report...")
    report = generate_report(result)
    println(report)

    print("\nSave report to file? (y/n): ")
    if lowercase(readline()) == "y"
        filename = "pvnp_report_$(result.session_id).txt"
        open(filename, "w") do f
            write(f, report)
        end
        println("✅ Report saved to: $filename")
    end
end

function run_interactive_benchmark()
    print("Enter problem type (SAT/TSP/GraphColoring/Knapsack): ")
    problem_type = readline()

    print("Enter sizes (comma-separated, e.g., 5,10,15): ")
    sizes_input = readline()
    sizes = parse.(Int, split(sizes_input, ','))

    println("\n🏃 Running benchmark...")
    results = benchmark_problem(problem_type, sizes)

    println("\n📊 Benchmark Results:")
    println("=" ^ 70)
    for (size, data) in sort(collect(results), by=x->parse(Int, x[1]))
        println("\nSize: $size")
        println("  Time Complexity: $(data["complexity"]["time_complexity"])")
        println("  Estimated Runtime: $(data["estimated_runtime"])")
    end
end

function run_interactive_complexity_analysis()
    print("Enter problem type (SAT/TSP/GraphColoring/Knapsack): ")
    problem_type = readline()

    print("Enter problem size: ")
    size = parse(Int, readline())

    analysis = analyze_complexity(problem_type, size)

    println("\n🔍 Complexity Analysis:")
    println("=" ^ 70)
    for (key, value) in analysis
        println("  $(key): $(value)")
    end
end

# ============================================================================
# Benchmark Mode
# ============================================================================

function benchmark_mode()
    println("╔════════════════════════════════════════════════════════════════════════╗")
    println("║               P vs NP Evaluation - Benchmark Mode                      ║")
    println("╚════════════════════════════════════════════════════════════════════════╝")
    println()

    problem_types = ["SAT", "TSP", "GraphColoring", "Knapsack"]
    sizes = [5, 8, 10, 12]

    for problem_type in problem_types
        println("\n" * "=" ^ 70)
        println("Benchmarking: $problem_type")
        println("=" ^ 70)

        results = benchmark_problem(problem_type, sizes)

        for (size, data) in sort(collect(results), by=x->parse(Int, x[1]))
            complexity = data["complexity"]
            println("\n📏 Size: $size")
            println("   ├─ Complexity Class: $(complexity["problem_class"])")
            println("   ├─ Time Complexity: $(complexity["time_complexity"])")
            println("   ├─ Estimated Operations: $(complexity["estimated_ops"])")
            println("   └─ Estimated Runtime: $(data["estimated_runtime"])")
        end
    end

    println("\n" * "=" ^ 70)
    println("✅ Benchmark complete!")
end

# ============================================================================
# Standard Evaluation Mode
# ============================================================================

function standard_evaluation(options::Dict{String, Any})
    problem_type = options["problem"]
    size = options["size"]
    models = options["models"]

    println("╔════════════════════════════════════════════════════════════════════════╗")
    println("║            P vs NP Evaluation using GenAI Agents                       ║")
    println("╚════════════════════════════════════════════════════════════════════════╝")
    println()
    println("Configuration:")
    println("  ├─ Problem Type: $problem_type")
    println("  ├─ Problem Size: $size")
    println("  └─ Models: $(join(models, ", "))")
    println()

    # Create and run evaluation session
    session = create_evaluation_session(problem_type, size, models)
    result = run_evaluation(session)

    # Generate and display report
    report = generate_report(result)
    println(report)

    # Save to file
    filename = "pvnp_report_$(result.session_id).txt"
    open(filename, "w") do f
        write(f, report)
    end
    println("📄 Full report saved to: $filename")
end

# ============================================================================
# Demonstration Mode
# ============================================================================

function run_demonstration()
    println("╔════════════════════════════════════════════════════════════════════════╗")
    println("║          P vs NP Demonstration - NP-Complete Algorithms                ║")
    println("╚════════════════════════════════════════════════════════════════════════╝")
    println()

    demonstrations = [
        ("SAT", 6, "Boolean Satisfiability"),
        ("TSP", 5, "Traveling Salesman Problem"),
        ("GraphColoring", 8, "Graph Coloring"),
        ("Knapsack", 10, "Knapsack Problem")
    ]

    for (problem_type, size, name) in demonstrations
        println("\n" * "─" ^ 70)
        println("🎯 Demonstrating: $name")
        println("─" ^ 70)

        analysis = analyze_complexity(problem_type, size)

        println("Problem Details:")
        println("  ├─ Type: $(analysis["problem_type"])")
        println("  ├─ Size: $(analysis["size"])")
        println("  ├─ Complexity Class: $(analysis["complexity_class"])")
        println("  ├─ Time Complexity: $(analysis["time_complexity"])")
        println("  ├─ Tractability: $(analysis["tractability"])")
        println("  └─ Estimated Runtime: $(analysis["estimated_runtime"])")

        println("\n🔬 Running mini evaluation...")
        session = create_evaluation_session(problem_type, size, ["ollama"])
        result = run_evaluation(session, timeout=30.0)

        println("✅ Completed in $(round(result.total_time, digits=2))s")
    end

    println("\n" * "═" ^ 70)
    println("🎓 Demonstration complete!")
    println("\nKey Insights about NP-Complete Problems:")
    println("  • All demonstrated problems are NP-Complete or NP-Hard")
    println("  • Solution time grows exponentially with problem size")
    println("  • No known polynomial-time algorithms exist for these problems")
    println("  • Finding efficient solutions remains an open problem in CS")
    println("═" ^ 70)
end

# ============================================================================
# Main Entry Point
# ============================================================================

function main()
    options = parse_arguments(ARGS)

    if options["help"]
        show_help()
        return
    end

    if options["interactive"]
        interactive_mode()
    elseif options["benchmark"]
        benchmark_mode()
    elseif length(ARGS) == 0
        # If no arguments, run demonstration
        run_demonstration()
    else
        standard_evaluation(options)
    end
end

# Run the program
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
