# P vs NP Evaluation System Using GenAI Agents

A comprehensive Julia-based system for evaluating NP-complete problems using multiple GenAI models to spawn pre-scripted agents. This system focuses on finding and analyzing NP-complete algorithms through automated agent-based evaluation.

## Overview

This program tackles one of computer science's most important questions: **P vs NP**. It implements various NP-complete problems and uses AI agents powered by different GenAI models to analyze, solve, and verify solutions to these computationally hard problems.

## Features

### 🎯 NP-Complete Problem Implementations

- **Boolean Satisfiability (SAT)**: The canonical NP-complete problem
- **Traveling Salesman Problem (TSP)**: Classic optimization problem
- **Graph Coloring**: Vertex coloring with minimal colors
- **Knapsack Problem**: Optimization under constraints
- **Hamiltonian Path**: Finding paths through graphs
- **Subset Sum**: Finding subsets that sum to a target
- **Vertex Cover**: Minimal vertex coverage of edges

### 🤖 Multi-Agent System

- **Solver Agents**: Attempt to find solutions to problems
- **Verifier Agents**: Verify correctness of solutions
- **Analyzer Agents**: Analyze computational complexity
- **Optimizer Agents**: Suggest algorithmic improvements
- **Researcher Agents**: Provide theoretical background

### 🧠 GenAI Model Support

- **Claude** (Anthropic): State-of-the-art reasoning
- **GPT** (OpenAI): General-purpose AI
- **Ollama** (Local): Privacy-focused local models

### 📊 Evaluation Features

- Automated problem instance generation
- Solution verification
- Performance benchmarking
- Complexity analysis
- Blockchain-based result tracking
- Comprehensive reporting

## Architecture

```
PvNP.jl (Main Program)
├── NPComplete.jl (Algorithm Implementations)
│   ├── SAT, TSP, Graph Coloring, Knapsack
│   ├── Solution verifiers
│   └── Complexity analyzers
│
├── AgentSpawner.jl (GenAI Integration)
│   ├── Multi-model support (Claude, GPT, Ollama)
│   ├── Agent role definitions
│   ├── Pre-scripted behaviors
│   └── Performance tracking
│
├── PvNPEvaluator.jl (Orchestration)
│   ├── Session management
│   ├── Problem instance generation
│   ├── Agent coordination
│   └── Result aggregation
│
├── Blockchain.jl (Result Verification)
│   └── Immutable result tracking
│
└── Grace.jl (Confidence Assessment)
    └── AI response quality evaluation
```

## Installation

### Prerequisites

1. **Julia** (v1.6 or higher)
```bash
# Download from https://julialang.org/downloads/
# Or use your package manager
```

2. **Julia Packages**
```julia
using Pkg
Pkg.add("HTTP")
Pkg.add("JSON")
Pkg.add("SHA")
Pkg.add("Dates")
Pkg.add("Statistics")
Pkg.add("Combinatorics")
Pkg.add("UUIDs")
```

3. **Optional: Ollama** (for local models)
```bash
# Install Ollama from https://ollama.ai
ollama pull mistral-nemo
```

### Setup

```bash
git clone <repository-url>
cd GraceLMP/JuliaMeetGrace
chmod +x PvNP.jl
```

## Usage

### Quick Start (Demonstration Mode)

Run without arguments to see a comprehensive demonstration:

```bash
julia PvNP.jl
```

This will:
- Demonstrate all four major NP-complete problems
- Show complexity analysis for each
- Run mini evaluations with local Ollama model
- Provide educational insights about P vs NP

### Interactive Mode

Launch the interactive menu system:

```bash
julia PvNP.jl --interactive
```

Features:
- Choose problem type interactively
- Configure problem size and models
- Run benchmarks
- Analyze complexity
- Save reports

### Standard Evaluation

Evaluate a specific problem:

```bash
# Evaluate SAT with default settings
julia PvNP.jl --problem SAT --size 10

# Evaluate TSP with multiple models
julia PvNP.jl --problem TSP --size 6 --models ollama,claude

# Evaluate Graph Coloring
julia PvNP.jl --problem GraphColoring --size 8 --models ollama

# Evaluate Knapsack
julia PvNP.jl --problem Knapsack --size 12 --models gpt
```

### Benchmark Mode

Run comprehensive benchmarks across problem sizes:

```bash
julia PvNP.jl --benchmark
```

This evaluates all problem types across multiple sizes and provides:
- Complexity class identification
- Time complexity analysis
- Runtime estimations
- Scalability insights

## Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `--problem <type>` | Problem type: SAT, TSP, GraphColoring, Knapsack | SAT |
| `--size <n>` | Problem size (number of variables/cities/vertices/items) | 10 |
| `--models <list>` | Comma-separated models: ollama,claude,gpt | ollama |
| `--benchmark` | Run benchmark mode across multiple sizes | false |
| `--interactive` | Launch interactive menu | false |
| `--help` | Show help message | false |

## Examples

### Example 1: Small SAT Problem

```bash
julia PvNP.jl --problem SAT --size 6
```

**Output:**
- Creates a 6-variable SAT instance with ~26 clauses
- Spawns solver, verifier, and analyzer agents
- Attempts to find satisfying assignment
- Verifies solution correctness
- Analyzes O(2^n) complexity
- Generates detailed report

### Example 2: TSP with Multiple Models

```bash
julia PvNP.jl --problem TSP --size 5 --models ollama,claude
```

**Output:**
- Creates a 5-city TSP instance
- Spawns 6 agents (3 per model)
- Finds optimal tour
- Compares agent performance
- Analyzes O(n!) complexity

### Example 3: Complexity Analysis

Within interactive mode:
1. Select "6. Analyze complexity"
2. Enter problem type: "GraphColoring"
3. Enter size: 15

**Output:**
```
🔍 Complexity Analysis:
══════════════════════════════════════════════════════════════════════════
  problem_type: GraphColoring
  size: 15
  complexity_class: NP-Complete
  time_complexity: O(k^n)
  space_complexity: O(n)
  estimated_operations: 437893890380859375
  estimated_runtime: 14.26 years
  tractability: Intractable
```

## Understanding the Output

### Session Report

A typical evaluation generates a comprehensive report:

```
╔════════════════════════════════════════════════════════════════════════╗
║              P vs NP EVALUATION SESSION REPORT                         ║
╚════════════════════════════════════════════════════════════════════════╝

SESSION INFORMATION:
├─ Session ID: [UUID]
├─ Problem Type: SAT
├─ Problem Size: 10
├─ Number of Agents: 3
└─ Total Execution Time: 2.456s

COMPLEXITY ANALYSIS:
├─ Complexity Class: NP-Complete
├─ Time Complexity: O(2^n)
├─ Space Complexity: O(n)
├─ Estimated Operations: 1024
└─ Estimated Runtime: 0.0 seconds

AGENT PERFORMANCE:
Agent 1:
├─ Role: SOLVER
├─ Model: OllamaModel
├─ Tasks Completed: 1
└─ Avg Execution Time: 0.823s

[... additional agents ...]

BLOCKCHAIN VERIFICATION:
└─ Latest Block Hash: [SHA256 hash]
```

## Programming Interface

### Using as a Library

```julia
include("PvNPEvaluator.jl")
using .PvNPEvaluator

# Create a session
session = create_evaluation_session("SAT", 8, ["ollama"])

# Run evaluation
result = run_evaluation(session)

# Generate report
report = generate_report(result)
println(report)

# Analyze complexity
analysis = analyze_complexity("TSP", 10)
```

### Creating Custom Problems

```julia
using .NPComplete

# Create custom SAT instance
clauses = [
    Clause([(1, true), (2, false), (3, true)]),
    Clause([(1, false), (3, false)]),
    Clause([(2, true), (3, true)])
]
sat_problem = SATInstance(3, clauses, "Custom SAT")

# Solve it
solution = solve_sat_bruteforce(sat_problem)
```

### Spawning Custom Agents

```julia
using .AgentSpawner

# Create custom agent with specific model
model = OllamaModel("llama2:latest")
agent = Agent(SOLVER, model, "Custom prompt here")

# Create task
task = AgentTask(
    "SAT",
    "Solve this SAT instance...",
    Dict("num_variables" => 5),
    "Boolean array",
    ["Must satisfy all clauses"]
)

# Execute task
result = execute_agent_task(agent, task)
```

## NP-Complete Problems Explained

### What is P vs NP?

- **P (Polynomial)**: Problems solvable in polynomial time O(n^k)
- **NP (Nondeterministic Polynomial)**: Problems verifiable in polynomial time
- **NP-Complete**: Hardest problems in NP; if any has polynomial solution, all NP problems do
- **NP-Hard**: At least as hard as NP-Complete problems

### Implemented Problems

#### 1. Boolean Satisfiability (SAT)
- **Input**: Boolean formula in CNF (Conjunctive Normal Form)
- **Question**: Is there an assignment making the formula true?
- **Complexity**: O(2^n) brute force
- **Significance**: First proven NP-complete problem (Cook-Levin theorem)

#### 2. Traveling Salesman Problem (TSP)
- **Input**: Cities with distances between them
- **Question**: What's the shortest tour visiting all cities once?
- **Complexity**: O(n!) brute force
- **Significance**: Classic optimization problem

#### 3. Graph Coloring
- **Input**: Graph and number of colors
- **Question**: Can vertices be colored so no adjacent vertices share a color?
- **Complexity**: O(k^n) brute force
- **Significance**: Applications in scheduling, register allocation

#### 4. Knapsack Problem
- **Input**: Items with weights/values, capacity constraint
- **Question**: What's the maximum value achievable within capacity?
- **Complexity**: O(2^n) brute force
- **Significance**: Resource allocation, cryptography

## Performance Considerations

### Problem Size Guidelines

| Size | SAT | TSP | GraphColoring | Knapsack | Runtime Estimate |
|------|-----|-----|---------------|----------|------------------|
| 5 | ✅ Fast | ✅ Fast | ✅ Fast | ✅ Fast | < 1 second |
| 10 | ✅ Fast | ✅ Fast | ✅ Fast | ✅ Fast | < 1 second |
| 15 | ⚠️ Slow | ❌ Very Slow | ⚠️ Slow | ⚠️ Slow | Minutes to hours |
| 20 | ❌ Impractical | ❌ Impractical | ❌ Impractical | ❌ Impractical | Years |

**Recommendation**: Start with size 5-10 for testing, max 12 for evaluation.

### Scalability Notes

- **Exponential Growth**: Runtime doubles (or worse) with each increment
- **Memory**: Generally linear, but can grow for some algorithms
- **Agent Overhead**: Each agent adds communication overhead
- **Network**: Claude/GPT require API calls (slower than Ollama)

## Advanced Features

### Blockchain Integration

All evaluation results are stored in an immutable blockchain:

```julia
# Results are automatically added to blockchain
session.blockchain  # Access the blockchain

# Each block contains:
# - Agent ID and role
# - Execution time
# - Timestamp
# - Cryptographic hash
```

### Confidence Assessment

Integrates with Grace.jl for AI response quality evaluation:

```julia
# Automatic assessment of agent responses
# - Reliability score
# - Performance score
# - Context coherence score
# - Overall confidence calculation
```

### Custom Model Configuration

```julia
# Use custom Claude model
claude = ClaudeModel("your-api-key", "claude-opus-4-5-20251101")

# Use custom GPT model
gpt = GPTModel("your-api-key", "gpt-4-turbo")

# Use custom Ollama model
ollama = OllamaModel("codellama:latest", "http://localhost:11434")

# Create session with custom models
session = create_evaluation_session("SAT", 10, [claude, gpt, ollama])
```

## Troubleshooting

### Common Issues

**1. "Package not found" error**
```bash
julia -e 'using Pkg; Pkg.add("PackageName")'
```

**2. Ollama connection failed**
- Ensure Ollama is running: `ollama serve`
- Check model is pulled: `ollama list`
- Verify URL: default is `http://localhost:11434`

**3. API key errors (Claude/GPT)**
- Set environment variables or pass keys directly
- Fallback: System uses mock responses if no API key

**4. Out of memory**
- Reduce problem size
- Use fewer agents
- Close other applications

**5. Slow execution**
- Problem size too large (exponential complexity!)
- Use smaller instances (≤ 10)
- Try Ollama instead of API-based models

## Educational Use

This system is ideal for:

### 🎓 Computer Science Education
- Teaching NP-completeness concepts
- Demonstrating computational complexity
- Visualizing exponential growth
- Understanding P vs NP question

### 🔬 Research
- Benchmarking AI problem-solving capabilities
- Comparing different GenAI models
- Analyzing agent-based approaches
- Studying heuristic effectiveness

### 💡 Experimentation
- Testing new algorithms
- Developing better heuristics
- Exploring AI-assisted problem solving
- Investigating quantum-classical comparisons

## Future Enhancements

Potential extensions:
- [ ] Approximation algorithms
- [ ] Quantum algorithm simulations
- [ ] Parallel agent execution
- [ ] Web-based visualization
- [ ] More NP-complete problems (Clique, Set Cover, etc.)
- [ ] Machine learning-based heuristics
- [ ] Distributed evaluation across multiple machines

## Contributing

Contributions welcome! Areas of interest:
- New NP-complete problem implementations
- Additional GenAI model integrations
- Performance optimizations
- Better visualization tools
- Educational materials

## References

### Foundational Papers
1. Cook, S. A. (1971). "The complexity of theorem-proving procedures"
2. Karp, R. M. (1972). "Reducibility among combinatorial problems"
3. Garey & Johnson (1979). "Computers and Intractability: A Guide to NP-Completeness"

### Problem-Specific
- SAT: Cook-Levin theorem
- TSP: Held-Karp algorithm, Christofides algorithm
- Graph Coloring: Welsh-Powell algorithm
- Knapsack: Dynamic programming approaches

## License

See LICENSE file in the repository root.

## Author

Created as part of the GraceLMP project - Julia meets Grace through AI-powered computational exploration.

## Acknowledgments

- Named in honor of Grace Hopper, pioneering computer scientist
- Built on Julia's high-performance scientific computing capabilities
- Leverages state-of-the-art GenAI models for intelligent agent behavior

---

**For questions, issues, or contributions, please open an issue on the repository.**

**Remember**: P vs NP is one of the Millennium Prize Problems. While this system won't solve it, it provides powerful tools for understanding why these problems are so challenging! 🧠💻
