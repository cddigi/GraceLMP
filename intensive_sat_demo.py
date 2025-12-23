#!/usr/bin/env python3
"""
Intensive SAT Solver Demo - Shows throughput progression with harder problem
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
        value = assignment[var_idx]
        if is_positive and value:
            return True
        elif not is_positive and not value:
            return True
    return False

def verify_sat_solution(instance, assignment):
    return all(evaluate_clause(clause, assignment) for clause in instance.clauses)

def solve_sat_intensive(instance):
    """Solve SAT with detailed throughput progression"""
    n = instance.num_variables
    total = 2 ** n

    print(f"\n{'='*85}")
    print(f"  INTENSIVE SAT SOLVER - EXPONENTIAL COMPLEXITY DEMONSTRATION")
    print(f"{'='*85}")
    print(f"\n📊 Problem Configuration:")
    print(f"  ├─ Variables: {n}")
    print(f"  ├─ Clauses: {len(instance.clauses)}")
    print(f"  ├─ Search Space: {total:,} boolean combinations")
    print(f"  ├─ Complexity Class: NP-Complete")
    print(f"  └─ Time Complexity: O(2^{n})")
    print(f"\n🚀 Initiating brute-force exhaustive search...")
    print(f"{'─'*85}\n")

    start = time.time()
    last_update = start
    update_interval = 0.05
    checked = 0
    checkpoint_interval = total // 20  # Report every 5%

    # Statistics tracking
    ops_per_second_samples = []

    for i in range(total):
        assignment = [bool((i >> j) & 1) for j in range(n)]

        if verify_sat_solution(instance, assignment):
            elapsed = time.time() - start
            throughput = checked / elapsed if elapsed > 0 else 0

            print(f"\n{'='*85}")
            print(f"  🎯 SOLUTION FOUND AT ITERATION {checked:,}")
            print(f"{'='*85}")
            print(f"\n✓ Satisfying Assignment:")
            print(f"  {assignment}")
            print(f"\n📈 Final Performance Metrics:")
            print(f"  ├─ Iterations Required: {checked:,} / {total:,}")
            print(f"  ├─ Search Efficiency: Found at {(checked/total)*100:.4f}% of space")
            print(f"  ├─ Execution Time: {elapsed:.4f} seconds")
            print(f"  ├─ Average Throughput: {throughput:,.0f} operations/sec")
            print(f"  ├─ Peak Throughput: {max(ops_per_second_samples) if ops_per_second_samples else throughput:,.0f} ops/sec")
            print(f"  └─ Operations Saved: {total - checked:,} ({((total-checked)/total)*100:.2f}%)")
            print(f"{'='*85}\n")
            return assignment

        checked += 1

        # Checkpoint reporting
        if checked % checkpoint_interval == 0:
            elapsed = time.time() - start
            progress = (checked / total) * 100
            throughput = checked / elapsed if elapsed > 0 else 0
            ops_per_second_samples.append(throughput)

            print(f"📍 Checkpoint: {progress:5.1f}% | "
                  f"{checked:,}/{total:,} | "
                  f"{throughput:,.0f} ops/s | "
                  f"{elapsed:.2f}s elapsed")

        # Real-time progress bar
        current = time.time()
        if current - last_update >= update_interval:
            elapsed = current - start
            progress = (checked / total) * 100
            throughput = checked / elapsed if elapsed > 0 else 0
            eta = ((total - checked) / throughput) if throughput > 0 else 0

            bar_width = 50
            filled = int(bar_width * checked / total)
            bar = '█' * filled + '░' * (bar_width - filled)

            print(f"\r⚡ [{bar}] {progress:6.2f}% | "
                  f"{checked:,} ops | "
                  f"{throughput:,.0f} ops/s | "
                  f"⏱ {elapsed:.2f}s | "
                  f"ETA {eta:.1f}s",
                  end='', flush=True)

            last_update = current

    # No solution found
    elapsed = time.time() - start
    throughput = checked / elapsed if elapsed > 0 else 0

    print(f"\n\n{'='*85}")
    print(f"  ⚠️  SEARCH SPACE EXHAUSTED - NO SOLUTION EXISTS")
    print(f"{'='*85}")
    print(f"\n📊 Complete Search Statistics:")
    print(f"  ├─ Total Iterations: {checked:,}")
    print(f"  ├─ Total Time: {elapsed:.3f} seconds")
    print(f"  ├─ Average Throughput: {throughput:,.0f} ops/sec")
    print(f"  └─ Peak Throughput: {max(ops_per_second_samples) if ops_per_second_samples else throughput:,.0f} ops/sec")
    print(f"{'='*85}\n")

    return None

def generate_unsatisfiable_sat(num_vars):
    """Generate a SAT instance that may require significant search"""
    clauses = []
    # Create clauses that make it interesting but not impossible
    for i in range(num_vars):
        for j in range(i+1, min(i+3, num_vars)):
            clauses.append(Clause([(i, True), (j, False)]))
            if len(clauses) < num_vars * 2:
                clauses.append(Clause([(i, False), (j, True)]))
    random.shuffle(clauses)
    return SATInstance(num_vars, clauses[:num_vars * 2])

def generate_satisfiable_sat(num_vars, num_clauses, clause_size=3):
    """Generate a likely satisfiable SAT instance"""
    clauses = []
    for _ in range(num_clauses):
        selected = random.sample(range(num_vars), min(clause_size, num_vars))
        literals = [(var, random.choice([True, False])) for var in selected]
        clauses.append(Clause(literals))
    return SATInstance(num_vars, clauses)

def main():
    print("\n" + "="*85)
    print("  🧠 P vs NP INTENSIVE EVALUATION - NP-COMPLETE PROBLEM SOLVING")
    print("="*85)
    print("\n  This demonstrates the EXPONENTIAL NATURE of NP-Complete problems")
    print("  Watch as the search space grows exponentially with each variable!")
    print("="*85)

    # Run a test that will show good progression
    print("\n\n🔬 TEST: Medium-sized SAT instance (showing exponential scaling)")
    print("─"*85)

    num_vars = 16  # 2^16 = 65,536 combinations
    num_clauses = 24

    random.seed(123)
    sat = generate_satisfiable_sat(num_vars, num_clauses, 3)

    print(f"\nGenerated {num_vars}-variable SAT problem")
    print(f"Search space: {2**num_vars:,} combinations")
    print(f"If this were n=20, search space would be: {2**20:,} (1,048,576)")
    print(f"If this were n=25, search space would be: {2**25:,} (33,554,432)")
    print(f"\nThis is why P ≠ NP matters: exponential growth is FAST! 🚀")

    solution = solve_sat_intensive(sat)

    if solution:
        print("🔍 Verification Process:")
        is_valid = verify_sat_solution(sat, solution)
        print(f"  └─ Solution Validity: {'✅ VERIFIED' if is_valid else '❌ FAILED'}")

    # Show exponential growth impact
    print("\n" + "="*85)
    print("  📈 EXPONENTIAL COMPLEXITY VISUALIZATION")
    print("="*85)
    print("\nHow problem size affects search space:")
    print(f"\n  {'n (vars)':<10} {'Combinations':<20} {'Est. Time @ 1M ops/s':<25} {'Growth':<15}")
    print("  " + "─"*75)

    prev = None
    for n in [8, 10, 12, 14, 16, 18, 20]:
        combs = 2 ** n
        time_est = combs / 1_000_000
        if time_est < 1:
            time_str = f"{time_est*1000:.1f}ms"
        elif time_est < 60:
            time_str = f"{time_est:.2f}s"
        elif time_est < 3600:
            time_str = f"{time_est/60:.2f}min"
        else:
            time_str = f"{time_est/3600:.2f}hrs"

        growth = f"{combs/prev:.1f}x" if prev else "-"
        print(f"  {n:<10} {combs:<20,} {time_str:<25} {growth:<15}")
        prev = combs

    print("\n  💡 Key Insight: Each +1 variable DOUBLES the search space!")
    print("     This is the essence of exponential complexity O(2^n)")

    print("\n" + "="*85)
    print("  ✅ DEMONSTRATION COMPLETE")
    print("="*85)
    print("\n  This is exactly what the Julia implementation does, plus:")
    print("  • Multi-agent GenAI analysis")
    print("  • Blockchain result verification")
    print("  • Cross-model performance comparison")
    print("  • Advanced complexity metrics")
    print("\n" + "="*85 + "\n")

if __name__ == "__main__":
    main()
