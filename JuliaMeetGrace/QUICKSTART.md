# Quick Start Guide - P vs NP Evaluation System

## 5-Minute Quick Start

### Step 1: Install Julia

```bash
# Ubuntu/Debian
wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.0-linux-x86_64.tar.gz
tar -xvzf julia-1.10.0-linux-x86_64.tar.gz
sudo mv julia-1.10.0 /opt/
sudo ln -s /opt/julia-1.10.0/bin/julia /usr/local/bin/julia

# macOS
brew install julia

# Windows
# Download from https://julialang.org/downloads/
```

### Step 2: Install Dependencies

```bash
cd GraceLMP/JuliaMeetGrace
julia -e 'using Pkg; Pkg.add(["HTTP", "JSON", "SHA", "Dates", "Statistics", "Combinatorics", "UUIDs"])'
```

### Step 3: Run Demo

```bash
# Run the demonstration (no configuration needed!)
julia PvNP.jl
```

That's it! You'll see evaluations of SAT, TSP, Graph Coloring, and Knapsack problems.

## Next Steps

### Interactive Mode

```bash
julia PvNP.jl --interactive
```

Try these options:
1. **Evaluate SAT** - Boolean satisfiability (easiest to start with)
2. **Run benchmark** - See how complexity grows
3. **Analyze complexity** - Understand time/space requirements

### Evaluate Specific Problems

```bash
# Small SAT problem (very fast)
julia PvNP.jl --problem SAT --size 6

# Traveling Salesman (fast for size 5)
julia PvNP.jl --problem TSP --size 5

# Graph Coloring (interesting visualization)
julia PvNP.jl --problem GraphColoring --size 8

# Knapsack optimization
julia PvNP.jl --problem Knapsack --size 10
```

### Benchmark Mode

```bash
# See exponential growth in action
julia PvNP.jl --benchmark
```

## Using with GenAI Models

### Option 1: Local Ollama (Recommended for beginners)

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull a model
ollama pull mistral-nemo

# Run evaluation
julia PvNP.jl --problem SAT --size 8 --models ollama
```

### Option 2: Claude API

```julia
# Edit AgentSpawner.jl or pass API key in code
julia PvNP.jl --problem TSP --size 6 --models claude
```

### Option 3: OpenAI GPT

```julia
julia PvNP.jl --problem SAT --size 8 --models gpt
```

### Option 4: Multiple Models (Compare)

```julia
julia PvNP.jl --problem SAT --size 6 --models ollama,claude,gpt
```

## Understanding Output

### What You'll See

1. **Session Creation**
   ```
   📊 Created evaluation session: <UUID>
      Problem: SAT with size 6
      Agents: 3 agents deployed
   ```

2. **Agent Execution**
   ```
   🤖 Executing agent: <UUID> (SOLVER)
      ✓ Completed in 0.823s
   ```

3. **Final Report**
   ```
   SESSION INFORMATION:
   ├─ Problem Type: SAT
   ├─ Problem Size: 6
   └─ Total Execution Time: 2.456s

   COMPLEXITY ANALYSIS:
   ├─ Complexity Class: NP-Complete
   ├─ Time Complexity: O(2^n)
   └─ Estimated Runtime: 0.0 seconds
   ```

### Report Files

Reports are automatically saved:
```
pvnp_report_<session-id>.txt
```

## Problem Size Recommendations

| Problem | Recommended Size | Max Practical | Why? |
|---------|-----------------|---------------|------|
| SAT | 8-10 | 15 | 2^n growth |
| TSP | 5-6 | 10 | n! growth |
| GraphColoring | 8-12 | 20 | k^n growth |
| Knapsack | 10-15 | 20 | 2^n growth |

**Rule of thumb**: Start small! Even size 10 → 15 can mean 32x longer runtime.

## Common Use Cases

### 1. Learn About NP-Completeness

```bash
# See the theory in action
julia PvNP.jl --benchmark

# Compare different problems
julia PvNP.jl --problem SAT --size 8
julia PvNP.jl --problem TSP --size 6
```

### 2. Compare AI Models

```bash
# Which model solves problems better?
julia PvNP.jl --problem SAT --size 8 --models ollama,claude
```

### 3. Research Complexity

```bash
# Interactive mode → "6. Analyze complexity"
julia PvNP.jl --interactive
```

### 4. Educational Demonstration

```bash
# Default demo mode shows everything
julia PvNP.jl
```

## Troubleshooting Quick Fixes

### "Package not found"
```bash
julia -e 'using Pkg; Pkg.add("HTTP")'
```

### "Ollama not responding"
```bash
ollama serve  # In one terminal
julia PvNP.jl --models ollama  # In another
```

### "Taking too long"
- Reduce problem size: `--size 5`
- Use fewer models: `--models ollama` (not ollama,claude,gpt)
- Remember: This is exponential complexity!

### "Out of memory"
- Close other programs
- Reduce size
- Use swap space

## Learning Path

### Week 1: Basics
1. Run demo mode
2. Try each problem type with size 5-6
3. Run benchmark to see complexity growth

### Week 2: Understanding
1. Use interactive mode
2. Analyze complexity for different sizes
3. Compare different problem types

### Week 3: Advanced
1. Compare multiple AI models
2. Try larger problem sizes (10-12)
3. Read generated reports in detail

### Week 4: Deep Dive
1. Modify agent prompts in AgentSpawner.jl
2. Add custom problem instances
3. Experiment with different complexity analyses

## Help & Resources

### Getting Help
```bash
julia PvNP.jl --help
```

### Documentation
- Full README: `PVNP_README.md`
- Code documentation: In-file docstrings
- Test suite: `test_pvnp.jl`

### Understanding Results

**Tractability**: Can this be solved in reasonable time?
- "Tractable" = Yes (< 1 billion operations)
- "Intractable" = No (would take years)

**Complexity Class**:
- "NP-Complete" = Hardest verifiable problems
- "NP-Hard" = At least as hard as NP-Complete

**Time Complexity**:
- O(2^n) = Doubles with each +1 size
- O(n!) = Factorial growth (very fast)
- O(k^n) = k to the power n

## Quick Reference

### Command Options
| Flag | Values | Default | Example |
|------|--------|---------|---------|
| --problem | SAT, TSP, GraphColoring, Knapsack | SAT | --problem TSP |
| --size | 1-20 | 10 | --size 8 |
| --models | ollama, claude, gpt | ollama | --models ollama,claude |
| --benchmark | (flag) | false | --benchmark |
| --interactive | (flag) | false | --interactive |
| --help | (flag) | false | --help |

### File Structure
```
JuliaMeetGrace/
├── PvNP.jl              # Main program ⭐
├── NPComplete.jl        # Algorithm implementations
├── AgentSpawner.jl      # AI agent system
├── PvNPEvaluator.jl     # Evaluation orchestration
├── Blockchain.jl        # Result verification
├── Grace.jl             # Confidence assessment
├── Decorators.jl        # Helper utilities
├── test_pvnp.jl         # Test suite
├── QUICKSTART.md        # This file
└── PVNP_README.md       # Full documentation
```

## What's Next?

After mastering the basics:

1. **Modify Agents**: Edit prompts in `AgentSpawner.jl`
2. **Add Problems**: Extend `NPComplete.jl` with new NP problems
3. **Custom Analysis**: Build on `PvNPEvaluator.jl`
4. **Visualizations**: Create graphs of complexity growth
5. **Research**: Use for academic projects on P vs NP

## Example Session

```bash
$ julia PvNP.jl --interactive

╔════════════════════════════════════════════════════════════════════════╗
║          P vs NP Evaluation System - Interactive Mode                 ║
╚════════════════════════════════════════════════════════════════════════╝

Available Commands:
  1. Evaluate SAT problem
  2. Evaluate TSP problem
  3. Evaluate Graph Coloring problem
  4. Evaluate Knapsack problem
  5. Run benchmark
  6. Analyze complexity
  7. Exit

Enter your choice (1-7): 1
Enter problem size (default 10): 8
Enter models (ollama/claude/gpt, comma-separated, default ollama): ollama

🔬 Creating evaluation session...
📊 Created evaluation session: abc123...
   Problem: SAT with size 8
   Agents: 3 agents deployed

⚙️  Running evaluation...
🤖 Executing agent: xyz789... (SOLVER)
   ✓ Completed in 0.756s
[... more agents ...]

✅ Evaluation session completed in 2.34s

📊 Generating report...
[... detailed report ...]

Save report to file? (y/n): y
✅ Report saved to: pvnp_report_abc123.txt
```

## Tips for Success

✅ **DO**:
- Start with small problem sizes (5-8)
- Use demo mode first to understand the system
- Read the complexity analysis carefully
- Experiment with different problem types
- Save interesting reports

❌ **DON'T**:
- Don't use size > 15 unless you have time to wait
- Don't run multiple large evaluations simultaneously
- Don't expect polynomial solutions to NP-Complete problems
- Don't skip the documentation

## Have Fun!

Remember: You're working with some of the hardest problems in computer science. Even small instances can be challenging. That's the beauty of P vs NP! 🧠💻

---

**Questions?** Open an issue or check `PVNP_README.md` for detailed documentation.
