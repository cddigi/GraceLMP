#!/usr/bin/env python3
"""
Comprehensive Throughput Test - Multiple Problem Sizes
Shows exponential scaling with live metrics
"""

import time
import random
import sys

class Clause:
    def __init__(self, literals):
        self.literals = literals

class SATInstance:
    def __init__(self, num_vars, clauses):
        self.num_variables = num_vars
        self.clauses = clauses

def evaluate_clause(clause, assignment):
    for var_idx, is_positive in clause.literals:
        if is_positive and assignment[var_idx]:
            return True
        elif not is_positive and not assignment[var_idx]:
            return True
    return False

def verify_sat_solution(instance, assignment):
    return all(evaluate_clause(clause, assignment) for clause in instance.clauses)

def solve_sat_timed(instance, show_progress=True):
    """Solve SAT with timing metrics"""
    n = instance.num_variables
    total = 2 ** n
    start = time.time()

    for i in range(total):
        assignment = [bool((i >> j) & 1) for j in range(n)]

        if verify_sat_solution(instance, assignment):
            elapsed = time.time() - start
            throughput = i / elapsed if elapsed > 0 else 0
            return {
                'found': True,
                'iterations': i,
                'time': elapsed,
                'throughput': throughput,
                'efficiency': (i / total) * 100,
                'solution': assignment
            }

        # Progress indicator for larger problems
        if show_progress and i % (total // 10 if total > 1000 else 100) == 0:
            elapsed = time.time() - start
            throughput = i / elapsed if elapsed > 0 else 0
            progress = (i / total) * 100
            print(f"    → {progress:5.1f}% | {i:,} ops | {throughput:,.0f} ops/s", flush=True)

    elapsed = time.time() - start
    throughput = total / elapsed if elapsed > 0 else 0
    return {
        'found': False,
        'iterations': total,
        'time': elapsed,
        'throughput': throughput,
        'efficiency': 100.0
    }

def generate_sat(num_vars, num_clauses=None, clause_size=3):
    """Generate SAT instance"""
    if num_clauses is None:
        num_clauses = int(num_vars * 2.5)

    clauses = []
    for _ in range(num_clauses):
        selected = random.sample(range(num_vars), min(clause_size, num_vars))
        literals = [(var, random.choice([True, False])) for var in selected]
        clauses.append(Clause(literals))
    return SATInstance(num_vars, clauses)

def main():
    print("\n" + "="*90)
    print("  🎯 COMPREHENSIVE P vs NP THROUGHPUT ANALYSIS")
    print("  📊 Testing Multiple Problem Sizes - Exponential Complexity in Action")
    print("="*90)

    # Test configurations
    test_sizes = [8, 10, 12, 14, 16]
    results = []

    print("\n🔬 Running systematic evaluation across problem sizes...")
    print("   Each test shows real algorithm performance with live throughput metrics\n")

    for size in test_sizes:
        print("─"*90)
        print(f"📏 TEST SIZE: n = {size} variables")
        print(f"   Search space: {2**size:,} combinations | Complexity: O(2^{size})")
        print("─"*90)

        random.seed(size * 100)  # Deterministic for each size
        sat = generate_sat(size)

        print(f"   Generated {len(sat.clauses)} clauses")
        print(f"   Starting exhaustive search...\n")

        show_progress = size >= 14  # Show progress for larger problems
        result = solve_sat_timed(sat, show_progress)
        results.append((size, result))

        print()
        if result['found']:
            print(f"   ✅ SOLUTION FOUND")
            print(f"   ├─ Iterations: {result['iterations']:,} / {2**size:,}")
            print(f"   ├─ Time: {result['time']:.6f} seconds")
            print(f"   ├─ Throughput: {result['throughput']:,.0f} ops/sec")
            print(f"   ├─ Efficiency: {result['efficiency']:.4f}% of search space")
            print(f"   └─ Speedup: {(2**size - result['iterations']):,} operations saved")
        else:
            print(f"   ⚠️  NO SOLUTION (full search)")
            print(f"   ├─ Iterations: {result['iterations']:,}")
            print(f"   ├─ Time: {result['time']:.6f} seconds")
            print(f"   └─ Throughput: {result['throughput']:,.0f} ops/sec")
        print()

    # Summary analysis
    print("\n" + "="*90)
    print("  📈 PERFORMANCE SUMMARY - EXPONENTIAL SCALING ANALYSIS")
    print("="*90)
    print()
    print(f"  {'Size':<6} {'Search Space':<15} {'Time (s)':<12} {'Throughput':<18} {'Growth Factor':<15}")
    print("  " + "─"*85)

    prev_time = None
    prev_space = None

    for size, result in results:
        space = 2 ** size
        time_s = result['time']
        throughput = result['throughput']

        growth = ""
        if prev_time and prev_space:
            time_growth = time_s / prev_time
            space_growth = space / prev_space
            growth = f"{time_growth:.2f}x time, {space_growth:.1f}x space"

        time_str = f"{time_s:.6f}"
        throughput_str = f"{throughput:,.0f} ops/s"

        print(f"  {size:<6} {space:<15,} {time_str:<12} {throughput_str:<18} {growth:<15}")

        prev_time = time_s
        prev_space = space

    print("\n  💡 Key Observations:")
    print("     • Search space doubles with each variable (+1 n)")
    print("     • Time grows exponentially, not linearly")
    print("     • Throughput varies based on solution location")
    print("     • This demonstrates why P ≠ NP is fundamental\n")

    # Complexity projection
    print("="*90)
    print("  🚀 COMPLEXITY PROJECTION - What if we scale further?")
    print("="*90)
    print()

    # Use average throughput from tests
    avg_throughput = sum(r[1]['throughput'] for r in results) / len(results)

    print(f"  Using observed average throughput: {avg_throughput:,.0f} ops/sec\n")
    print(f"  {'n':<5} {'Combinations':<20} {'Projected Time':<20} {'Feasibility':<15}")
    print("  " + "─"*75)

    for n in [18, 20, 22, 24, 26, 28, 30]:
        combs = 2 ** n
        projected_time = combs / avg_throughput

        if projected_time < 1:
            time_str = f"{projected_time*1000:.0f}ms"
            feasible = "✅ Fast"
        elif projected_time < 60:
            time_str = f"{projected_time:.1f}s"
            feasible = "✅ Feasible"
        elif projected_time < 3600:
            time_str = f"{projected_time/60:.1f}min"
            feasible = "⚠️  Slow"
        elif projected_time < 86400:
            time_str = f"{projected_time/3600:.1f}hrs"
            feasible = "❌ Impractical"
        else:
            time_str = f"{projected_time/86400:.1f}days"
            feasible = "❌ Infeasible"

        print(f"  {n:<5} {combs:<20,} {time_str:<20} {feasible:<15}")

    print("\n  ⚠️  Notice: n=30 has 1 BILLION combinations!")
    print("     This is the NP-Complete challenge: exponential explosion\n")

    print("="*90)
    print("  🎓 EDUCATIONAL INSIGHTS")
    print("="*90)
    print("""
  P vs NP Question:
  ─────────────────
  • P: Problems solvable in polynomial time O(n^k)
  • NP: Problems verifiable in polynomial time
  • NP-Complete: Hardest problems in NP

  What we demonstrated:
  ────────────────────
  • SAT is NP-Complete (proven by Cook-Levin theorem)
  • Solving requires exponential time O(2^n)
  • Verifying a solution is polynomial O(n)
  • No known polynomial-time algorithm exists for solving

  Why it matters:
  ───────────────
  • Cryptography relies on this hardness
  • Many real-world problems are NP-Complete
  • Finding P=NP would revolutionize computing
  • Most believe P ≠ NP (but unproven!)

  This Julia system adds:
  ──────────────────────
  • GenAI agents for intelligent solving
  • Multiple problem types (TSP, Graph Coloring, etc.)
  • Blockchain verification of results
  • Multi-model AI comparison
""")

    print("="*90)
    print("  ✅ COMPREHENSIVE THROUGHPUT ANALYSIS COMPLETE")
    print("="*90)
    print()

if __name__ == "__main__":
    main()
