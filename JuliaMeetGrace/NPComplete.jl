"""
NPComplete.jl - NP-Complete Algorithm Implementations

This module implements various NP-complete problems for P vs NP evaluation:
- Boolean Satisfiability (SAT)
- Traveling Salesman Problem (TSP)
- Graph Coloring
- Knapsack Problem
- Hamiltonian Path
- Subset Sum
- Vertex Cover
"""

module NPComplete

export SATInstance, TSPInstance, GraphColoringInstance, KnapsackInstance
export HamiltonianPathInstance, SubsetSumInstance, VertexCoverInstance
export solve_sat_bruteforce, solve_tsp_bruteforce, solve_graph_coloring_bruteforce
export solve_knapsack_bruteforce, verify_sat_solution, verify_tsp_solution
export generate_random_sat, generate_random_tsp, generate_random_graph
export get_problem_complexity, estimate_runtime

using Random
using Combinatorics

# ============================================================================
# Boolean Satisfiability (SAT) Problem
# ============================================================================

struct Clause
    literals::Vector{Tuple{Int, Bool}}  # (variable_index, is_positive)
end

struct SATInstance
    num_variables::Int
    clauses::Vector{Clause}
    name::String

    function SATInstance(num_variables::Int, clauses::Vector{Clause}, name::String="SAT Problem")
        new(num_variables, clauses, name)
    end
end

function evaluate_clause(clause::Clause, assignment::Vector{Bool})::Bool
    for (var_idx, is_positive) in clause.literals
        value = assignment[var_idx]
        if is_positive && value
            return true
        elseif !is_positive && !value
            return true
        end
    end
    return false
end

function verify_sat_solution(instance::SATInstance, assignment::Vector{Bool})::Bool
    if length(assignment) != instance.num_variables
        return false
    end
    return all(evaluate_clause(clause, assignment) for clause in instance.clauses)
end

function solve_sat_bruteforce(instance::SATInstance)::Union{Vector{Bool}, Nothing}
    n = instance.num_variables
    for i in 0:(2^n - 1)
        assignment = [Bool((i >> j) & 1) for j in 0:(n-1)]
        if verify_sat_solution(instance, assignment)
            return assignment
        end
    end
    return nothing
end

function generate_random_sat(num_vars::Int, num_clauses::Int, clause_size::Int=3)::SATInstance
    clauses = Clause[]
    for _ in 1:num_clauses
        literals = Tuple{Int, Bool}[]
        selected_vars = randperm(num_vars)[1:min(clause_size, num_vars)]
        for var in selected_vars
            push!(literals, (var, rand(Bool)))
        end
        push!(clauses, Clause(literals))
    end
    return SATInstance(num_vars, clauses, "Random $(num_vars)-SAT")
end

# ============================================================================
# Traveling Salesman Problem (TSP)
# ============================================================================

struct TSPInstance
    num_cities::Int
    distance_matrix::Matrix{Float64}
    name::String

    function TSPInstance(distance_matrix::Matrix{Float64}, name::String="TSP Problem")
        n = size(distance_matrix, 1)
        if size(distance_matrix, 2) != n
            error("Distance matrix must be square")
        end
        new(n, distance_matrix, name)
    end
end

function calculate_tour_distance(instance::TSPInstance, tour::Vector{Int})::Float64
    total = 0.0
    for i in 1:(length(tour)-1)
        total += instance.distance_matrix[tour[i], tour[i+1]]
    end
    total += instance.distance_matrix[tour[end], tour[1]]
    return total
end

function verify_tsp_solution(instance::TSPInstance, tour::Vector{Int}, max_distance::Float64)::Bool
    if length(tour) != instance.num_cities || length(unique(tour)) != instance.num_cities
        return false
    end
    return calculate_tour_distance(instance, tour) <= max_distance
end

function solve_tsp_bruteforce(instance::TSPInstance)::Tuple{Vector{Int}, Float64}
    best_tour = collect(1:instance.num_cities)
    best_distance = calculate_tour_distance(instance, best_tour)

    for perm in permutations(1:instance.num_cities)
        dist = calculate_tour_distance(instance, collect(perm))
        if dist < best_distance
            best_distance = dist
            best_tour = collect(perm)
        end
    end

    return best_tour, best_distance
end

function generate_random_tsp(num_cities::Int; max_dist::Float64=100.0)::TSPInstance
    dist_matrix = zeros(Float64, num_cities, num_cities)
    for i in 1:num_cities
        for j in (i+1):num_cities
            dist = rand() * max_dist
            dist_matrix[i, j] = dist
            dist_matrix[j, i] = dist
        end
    end
    return TSPInstance(dist_matrix, "Random $(num_cities)-city TSP")
end

# ============================================================================
# Graph Coloring Problem
# ============================================================================

struct GraphColoringInstance
    num_vertices::Int
    edges::Vector{Tuple{Int, Int}}
    num_colors::Int
    name::String

    function GraphColoringInstance(num_vertices::Int, edges::Vector{Tuple{Int, Int}},
                                   num_colors::Int, name::String="Graph Coloring")
        new(num_vertices, edges, num_colors, name)
    end
end

function verify_coloring(instance::GraphColoringInstance, coloring::Vector{Int})::Bool
    if length(coloring) != instance.num_vertices
        return false
    end

    if any(c < 1 || c > instance.num_colors for c in coloring)
        return false
    end

    for (u, v) in instance.edges
        if coloring[u] == coloring[v]
            return false
        end
    end

    return true
end

function solve_graph_coloring_bruteforce(instance::GraphColoringInstance)::Union{Vector{Int}, Nothing}
    n = instance.num_vertices
    k = instance.num_colors

    function try_coloring(colors::Vector{Int})
        if length(colors) == n
            return verify_coloring(instance, colors) ? colors : nothing
        end

        for color in 1:k
            new_colors = vcat(colors, color)
            result = try_coloring(new_colors)
            if result !== nothing
                return result
            end
        end
        return nothing
    end

    return try_coloring(Int[])
end

function generate_random_graph(num_vertices::Int, edge_probability::Float64=0.3)::GraphColoringInstance
    edges = Tuple{Int, Int}[]
    for i in 1:num_vertices
        for j in (i+1):num_vertices
            if rand() < edge_probability
                push!(edges, (i, j))
            end
        end
    end

    num_colors = max(3, floor(Int, num_vertices / 3))
    return GraphColoringInstance(num_vertices, edges, num_colors,
                                "Random $(num_vertices)-vertex graph")
end

# ============================================================================
# Knapsack Problem
# ============================================================================

struct KnapsackInstance
    num_items::Int
    weights::Vector{Int}
    values::Vector{Int}
    capacity::Int
    name::String

    function KnapsackInstance(weights::Vector{Int}, values::Vector{Int},
                            capacity::Int, name::String="Knapsack Problem")
        if length(weights) != length(values)
            error("Weights and values must have same length")
        end
        new(length(weights), weights, values, capacity, name)
    end
end

function verify_knapsack_solution(instance::KnapsackInstance, selection::Vector{Bool})::Tuple{Bool, Int}
    if length(selection) != instance.num_items
        return false, 0
    end

    total_weight = sum(instance.weights[i] for i in 1:instance.num_items if selection[i])
    total_value = sum(instance.values[i] for i in 1:instance.num_items if selection[i])

    return total_weight <= instance.capacity, total_value
end

function solve_knapsack_bruteforce(instance::KnapsackInstance)::Tuple{Vector{Bool}, Int}
    best_selection = fill(false, instance.num_items)
    best_value = 0

    for i in 0:(2^instance.num_items - 1)
        selection = [Bool((i >> j) & 1) for j in 0:(instance.num_items-1)]
        is_valid, value = verify_knapsack_solution(instance, selection)
        if is_valid && value > best_value
            best_value = value
            best_selection = selection
        end
    end

    return best_selection, best_value
end

# ============================================================================
# Hamiltonian Path Problem
# ============================================================================

struct HamiltonianPathInstance
    num_vertices::Int
    edges::Vector{Tuple{Int, Int}}
    name::String

    function HamiltonianPathInstance(num_vertices::Int, edges::Vector{Tuple{Int, Int}},
                                    name::String="Hamiltonian Path")
        new(num_vertices, edges, name)
    end
end

function verify_hamiltonian_path(instance::HamiltonianPathInstance, path::Vector{Int})::Bool
    if length(path) != instance.num_vertices || length(unique(path)) != instance.num_vertices
        return false
    end

    edge_set = Set(instance.edges)
    for i in 1:(length(path)-1)
        u, v = path[i], path[i+1]
        if !((u, v) in edge_set || (v, u) in edge_set)
            return false
        end
    end

    return true
end

# ============================================================================
# Subset Sum Problem
# ============================================================================

struct SubsetSumInstance
    numbers::Vector{Int}
    target::Int
    name::String

    function SubsetSumInstance(numbers::Vector{Int}, target::Int, name::String="Subset Sum")
        new(numbers, target, name)
    end
end

function verify_subset_sum(instance::SubsetSumInstance, selection::Vector{Bool})::Bool
    total = sum(instance.numbers[i] for i in 1:length(instance.numbers) if selection[i])
    return total == instance.target
end

# ============================================================================
# Vertex Cover Problem
# ============================================================================

struct VertexCoverInstance
    num_vertices::Int
    edges::Vector{Tuple{Int, Int}}
    cover_size::Int
    name::String

    function VertexCoverInstance(num_vertices::Int, edges::Vector{Tuple{Int, Int}},
                                cover_size::Int, name::String="Vertex Cover")
        new(num_vertices, edges, cover_size, name)
    end
end

function verify_vertex_cover(instance::VertexCoverInstance, cover::Vector{Int})::Bool
    if length(cover) > instance.cover_size
        return false
    end

    cover_set = Set(cover)
    for (u, v) in instance.edges
        if !(u in cover_set || v in cover_set)
            return false
        end
    end

    return true
end

# ============================================================================
# Complexity Analysis
# ============================================================================

function get_problem_complexity(problem_type::String, n::Int)::Dict{String, Any}
    complexities = Dict(
        "SAT" => Dict(
            "time_complexity" => "O(2^n)",
            "space_complexity" => "O(n)",
            "estimated_ops" => 2^n,
            "problem_class" => "NP-Complete"
        ),
        "TSP" => Dict(
            "time_complexity" => "O(n!)",
            "space_complexity" => "O(n)",
            "estimated_ops" => factorial(min(n, 20)),
            "problem_class" => "NP-Hard"
        ),
        "GraphColoring" => Dict(
            "time_complexity" => "O(k^n)",
            "space_complexity" => "O(n)",
            "estimated_ops" => n^n,
            "problem_class" => "NP-Complete"
        ),
        "Knapsack" => Dict(
            "time_complexity" => "O(2^n)",
            "space_complexity" => "O(n)",
            "estimated_ops" => 2^n,
            "problem_class" => "NP-Complete"
        )
    )

    return get(complexities, problem_type, Dict("error" => "Unknown problem type"))
end

function estimate_runtime(num_operations::Int, ops_per_second::Float64=1e9)::String
    seconds = num_operations / ops_per_second

    if seconds < 60
        return "$(round(seconds, digits=2)) seconds"
    elseif seconds < 3600
        return "$(round(seconds/60, digits=2)) minutes"
    elseif seconds < 86400
        return "$(round(seconds/3600, digits=2)) hours"
    elseif seconds < 31536000
        return "$(round(seconds/86400, digits=2)) days"
    else
        return "$(round(seconds/31536000, digits=2)) years"
    end
end

end # module NPComplete
