// RUN: fir-opt --stack-arrays %s | FileCheck %s

// Simplest transformation
func.func @simple() {
  %0 = fir.allocmem !fir.array<42xi32>
  fir.freemem %0 : !fir.heap<!fir.array<42xi32>>
  return
}
// CHECK: func.func @simple() {
// CHECK-NEXT: fir.alloca !fir.array<42xi32>
// CHECK-NEXT: return
// CHECK-NEXT: }

// Check fir.must_be_heap allocations are not moved
func.func @must_be_heap() {
  %0 = fir.allocmem !fir.array<42xi32> {fir.must_be_heap = true}
  fir.freemem %0 : !fir.heap<!fir.array<42xi32>>
  return
}
// CHECK:      func.func @must_be_heap() {
// CHECK-NEXT:   %[[ALLOC:.*]] = fir.allocmem !fir.array<42xi32> {fir.must_be_heap = true}
// CHECK-NEXT:   fir.freemem %[[ALLOC]] : !fir.heap<!fir.array<42xi32>>
// CHECK-NEXT:   return
// CHECK-NEXT: }

// Check the data-flow-analysis can detect cases where we aren't sure if memory
// is freed by the end of the function
func.func @dfa1(%arg0: !fir.ref<!fir.logical<4>> {fir.bindc_name = "cond"}) {
  %7 = arith.constant 42 : index
  %8 = fir.allocmem !fir.array<?xi32>, %7 {uniq_name = "_QFdfa1Earr.alloc"}
  %9 = fir.load %arg0 : !fir.ref<!fir.logical<4>>
  %10 = fir.convert %9 : (!fir.logical<4>) -> i1
  fir.if %10 {
    fir.freemem %8 : !fir.heap<!fir.array<?xi32>>
  } else {
  }
  return
}
// CHECK:      func.func @dfa1(%arg0: !fir.ref<!fir.logical<4>> {fir.bindc_name = "cond"}) {
// CHECK-NEXT:   %[[C42:.*]] = arith.constant 42 : index
// CHECK-NEXT:   %[[MEM:.*]] = fir.allocmem !fir.array<?xi32>, %[[C42]] {uniq_name = "_QFdfa1Earr.alloc"}
// CHECK-NEXT:   %[[LOGICAL:.*]] = fir.load %arg0 : !fir.ref<!fir.logical<4>>
// CHECK-NEXT:   %[[BOOL:.*]] = fir.convert %[[LOGICAL]] : (!fir.logical<4>) -> i1
// CHECK-NEXT:   fir.if %[[BOOL]] {
// CHECK-NEXT:     fir.freemem %[[MEM]] : !fir.heap<!fir.array<?xi32>>
// CHECK-NEXT:   } else {
// CHECK-NEXT:   }
// CHECK-NEXT:   return
// CHECK-NEXT: }

// Check scf.if
func.func @dfa2(%arg0: i1) {
  %a = fir.allocmem !fir.array<1xi8>
  scf.if %arg0 {
    fir.freemem %a : !fir.heap<!fir.array<1xi8>>
  } else {
  }
  return
}
// CHECK:     func.func @dfa2(%arg0: i1) {
// CHECK-NEXT:  %[[MEM:.*]] = fir.allocmem !fir.array<1xi8>
// CHECK-NEXT:  scf.if %arg0 {
// CHECK-NEXT:    fir.freemem %[[MEM]] : !fir.heap<!fir.array<1xi8>>
// CHECK-NEXT:  } else {
// CHECK-NEXT:  }
// CHECK-NEXT:  return
// CHECK-NEXT:  }

// Check freemem in both regions
func.func @dfa3(%arg0: i1) {
  %a = fir.allocmem !fir.array<1xi8>
  fir.if %arg0 {
    fir.freemem %a : !fir.heap<!fir.array<1xi8>>
  } else {
    fir.freemem %a : !fir.heap<!fir.array<1xi8>>
  }
  return
}
// CHECK:     func.func @dfa3(%arg0: i1) {
// CHECK-NEXT:  %[[MEM:.*]] = fir.alloca !fir.array<1xi8>
// CHECK-NEXT:  fir.if %arg0 {
// CHECK-NEXT:  } else {
// CHECK-NEXT:  }
// CHECK-NEXT:  return
// CHECK-NEXT:  }

func.func private @dfa3a_foo(!fir.ref<!fir.array<1xi8>>) -> ()
func.func private @dfa3a_bar(!fir.ref<!fir.array<1xi8>>) -> ()

// Check freemem in both regions, with other uses
func.func @dfa3a(%arg0: i1) {
  %a = fir.allocmem !fir.array<1xi8>
  fir.if %arg0 {
    %ref = fir.convert %a : (!fir.heap<!fir.array<1xi8>>) -> !fir.ref<!fir.array<1xi8>>
    func.call @dfa3a_foo(%ref) : (!fir.ref<!fir.array<1xi8>>) -> ()
    fir.freemem %a : !fir.heap<!fir.array<1xi8>>
  } else {
    %ref = fir.convert %a : (!fir.heap<!fir.array<1xi8>>) -> !fir.ref<!fir.array<1xi8>>
    func.call @dfa3a_bar(%ref) : (!fir.ref<!fir.array<1xi8>>) -> ()
    fir.freemem %a : !fir.heap<!fir.array<1xi8>>
  }
  return
}
// CHECK:     func.func @dfa3a(%arg0: i1) {
// CHECK-NEXT:  %[[MEM:.*]] = fir.alloca !fir.array<1xi8>
// CHECK-NEXT:  %[[HEAP:.*]] = fir.convert %[[MEM]] : (!fir.ref<!fir.array<1xi8>>) -> !fir.heap<!fir.array<1xi8>>
// CHECK-NEXT:  fir.if %arg0 {
// CHECK-NEXT:    %[[REF:.*]] = fir.convert %[[HEAP]] : (!fir.heap<!fir.array<1xi8>>) -> !fir.ref<!fir.array<1xi8>>
// CHECK-NEXT:    func.call @dfa3a_foo(%[[REF]])
// CHECK-NEXT:  } else {
// CHECK-NEXT:    %[[REF:.*]] = fir.convert %[[HEAP]] : (!fir.heap<!fir.array<1xi8>>) -> !fir.ref<!fir.array<1xi8>>
// CHECK-NEXT:    func.call @dfa3a_bar(%[[REF]])
// CHECK-NEXT:  }
// CHECK-NEXT:  return
// CHECK-NEXT:  }

// check the alloca is placed after all operands become available
func.func @placement1() {
  // do some stuff with other ssa values
  %1 = arith.constant 1 : index
  %2 = arith.constant 2 : index
  %3 = arith.addi %1, %2 : index
  // operand is now available
  %4 = fir.allocmem !fir.array<?xi32>, %3
  // ...
  fir.freemem %4 : !fir.heap<!fir.array<?xi32>>
  return
}
// CHECK:      func.func @placement1() {
// CHECK-NEXT:   %[[ARG:.*]] = arith.constant 3 : index
// CHECK-NEXT:   %[[MEM:.*]] = fir.alloca !fir.array<?xi32>, %[[ARG]]
// CHECK-NEXT:   return
// CHECK-NEXT: }

// check that if there are no operands, then the alloca is placed early
func.func @placement2() {
  // do some stuff with other ssa values
  %1 = arith.constant 1 : index
  %2 = arith.constant 2 : index
  %3 = arith.addi %1, %2 : index
  %4 = fir.allocmem !fir.array<42xi32>
  // ...
  fir.freemem %4 : !fir.heap<!fir.array<42xi32>>
  return
}
// CHECK:      func.func @placement2() {
// CHECK-NEXT:   %[[MEM:.*]] = fir.alloca !fir.array<42xi32>
// CHECK-NEXT:   %[[ONE:.*]] = arith.constant 1 : index
// CHECK-NEXT:   %[[TWO:.*]] = arith.constant 2 : index
// CHECK-NEXT:   %[[SUM:.*]] = arith.addi %[[ONE]], %[[TWO]] : index
// CHECK-NEXT:   return
// CHECK-NEXT: }

// check that stack allocations which must be placed in loops use stacksave
func.func @placement3() {
  %c1 = arith.constant 1 : index
  %c1_i32 = fir.convert %c1 : (index) -> i32
  %c2 = arith.constant 2 : index
  %c10 = arith.constant 10 : index
  %0:2 = fir.do_loop %arg0 = %c1 to %c10 step %c1 iter_args(%arg1 = %c1_i32) -> (index, i32) {
    %3 = arith.addi %c1, %c2 : index
    // operand is now available
    %4 = fir.allocmem !fir.array<?xi32>, %3
    // ...
    fir.freemem %4 : !fir.heap<!fir.array<?xi32>>
    fir.result %3, %c1_i32 : index, i32
  }
  return
}
// CHECK:      func.func @placement3() {
// CHECK-NEXT:   %[[C1:.*]] = arith.constant 1 : index
// CHECK-NEXT:   %[[C1_I32:.*]] = fir.convert %[[C1]] : (index) -> i32
// CHECK-NEXT:   %[[C2:.*]] = arith.constant 2 : index
// CHECK-NEXT:   %[[C10:.*]] = arith.constant 10 : index
// CHECK-NEXT:   fir.do_loop
// CHECK-NEXT:     %[[SUM:.*]] = arith.addi %[[C1]], %[[C2]] : index
// CHECK-NEXT:     %[[SP:.*]] = llvm.intr.stacksave : !llvm.ptr
// CHECK-NEXT:     %[[MEM:.*]] = fir.alloca !fir.array<?xi32>, %[[SUM]]
// CHECK-NEXT:     llvm.intr.stackrestore %[[SP]] : !llvm.ptr
// CHECK-NEXT:     fir.result
// CHECK-NEXT:   }
// CHECK-NEXT:   return
// CHECK-NEXT: }

// check that stack save/restore are used in CFG loops
func.func @placement4(%arg0 : i1) {
  %c1 = arith.constant 1 : index
  %c1_i32 = fir.convert %c1 : (index) -> i32
  %c2 = arith.constant 2 : index
  %c10 = arith.constant 10 : index
  cf.br ^bb1
^bb1:
  %3 = arith.addi %c1, %c2 : index
  // operand is now available
  %4 = fir.allocmem !fir.array<?xi32>, %3
  // ...
  fir.freemem %4 : !fir.heap<!fir.array<?xi32>>
  cf.cond_br %arg0, ^bb1, ^bb2
^bb2:
  return
}
// CHECK:      func.func @placement4(%arg0: i1) {
// CHECK-NEXT:   %[[C1:.*]] = arith.constant 1 : index
// CHECK-NEXT:   %[[C1_I32:.*]] = fir.convert %[[C1]] : (index) -> i32
// CHECK-NEXT:   %[[C10:.*]] = arith.constant 10 : index
// CHECK-NEXT:   cf.br ^bb1
// CHECK-NEXT: ^bb1:
// CHECK-NEXT:   %[[C3:.*]] = arith.constant 3 : index
// CHECK-NEXT:   %[[SP:.*]] = llvm.intr.stacksave : !llvm.ptr
// CHECK-NEXT:   %[[MEM:.*]] = fir.alloca !fir.array<?xi32>, %[[C3]]
// CHECK-NEXT:   llvm.intr.stackrestore %[[SP]] : !llvm.ptr
// CHECK-NEXT:   cf.cond_br %arg0, ^bb1, ^bb2
// CHECK-NEXT: ^bb2:
// CHECK-NEXT:   return
// CHECK-NEXT: }

// check that stacksave is not used when there is an intervening alloca
func.func @placement5() {
  %c1 = arith.constant 1 : index
  %c1_i32 = fir.convert %c1 : (index) -> i32
  %c2 = arith.constant 2 : index
  %c10 = arith.constant 10 : index
  %0:2 = fir.do_loop %arg0 = %c1 to %c10 step %c1 iter_args(%arg1 = %c1_i32) -> (index, i32) {
    %3 = arith.addi %c1, %c2 : index
    // operand is now available
    %4 = fir.allocmem !fir.array<?xi32>, %3
    %5 = fir.alloca i32
    fir.freemem %4 : !fir.heap<!fir.array<?xi32>>
    fir.result %3, %c1_i32 : index, i32
  }
  return
}
// CHECK:      func.func @placement5() {
// CHECK-NEXT:   %[[C1:.*]] = arith.constant 1 : index
// CHECK-NEXT:   %[[C1_I32:.*]] = fir.convert %[[C1]] : (index) -> i32
// CHECK-NEXT:   %[[C2:.*]] = arith.constant 2 : index
// CHECK-NEXT:   %[[C10:.*]] = arith.constant 10 : index
// CHECK-NEXT:   fir.do_loop
// CHECK-NEXT:     %[[SUM:.*]] = arith.addi %[[C1]], %[[C2]] : index
// CHECK-NEXT:     %[[MEM:.*]] = fir.allocmem !fir.array<?xi32>, %[[SUM]]
// CHECK-NEXT:     %[[IDX:.*]] = fir.alloca i32
// CHECK-NEXT:     fir.freemem %[[MEM]] : !fir.heap<!fir.array<?xi32>>
// CHECK-NEXT:     fir.result
// CHECK-NEXT:   }
// CHECK-NEXT:   return
// CHECK-NEXT: }

// check that stack save/restore are not used when the memalloc and freemem are
// in different blocks
func.func @placement6(%arg0: i1) {
  %c1 = arith.constant 1 : index
  %c1_i32 = fir.convert %c1 : (index) -> i32
  %c2 = arith.constant 2 : index
  %c10 = arith.constant 10 : index
  cf.br ^bb1
^bb1:
  %3 = arith.addi %c1, %c2 : index
  // operand is now available
  %4 = fir.allocmem !fir.array<?xi32>, %3
  // ...
  cf.cond_br %arg0, ^bb2, ^bb3
^bb2:
  // ...
  fir.freemem %4 : !fir.heap<!fir.array<?xi32>>
  cf.br ^bb1
^bb3:
  // ...
  fir.freemem %4 : !fir.heap<!fir.array<?xi32>>
  cf.br ^bb1
}
// CHECK:      func.func @placement6(%arg0: i1) {
// CHECK-NEXT:   %[[c1:.*]] = arith.constant 1 : index
// CHECK-NEXT:   %[[c1_i32:.*]] = fir.convert %[[c1]] : (index) -> i32
// CHECK-NEXT:   %[[c2:.*]] = arith.constant 2 : index
// CHECK-NEXT:   %[[c10:.*]] = arith.constant 10 : index
// CHECK-NEXT:   cf.br ^bb1
// CHECK-NEXT: ^bb1:
// CHECK-NEXT:   %[[ADD:.*]] = arith.addi %[[c1]], %[[c2]] : index
// CHECK-NEXT:   %[[MEM:.*]] = fir.allocmem !fir.array<?xi32>, %[[ADD]]
// CHECK-NEXT:   cf.cond_br %arg0, ^bb2, ^bb3
// CHECK-NEXT: ^bb2:
// CHECK-NEXT:   fir.freemem %[[MEM]] : !fir.heap<!fir.array<?xi32>>
// CHECK-NEXT:   cf.br ^bb1
// CHECK-NEXT: ^bb3:
// CHECK-NEXT:   fir.freemem %[[MEM]] : !fir.heap<!fir.array<?xi32>>
// CHECK-NEXT:   cf.br ^bb1
// CHECK-NEXT: }

// Check multiple returns, where the memory is always freed
func.func @returns(%arg0: i1) {
  %0 = fir.allocmem !fir.array<42xi32>
  cf.cond_br %arg0, ^bb1, ^bb2
^bb1:
  fir.freemem %0 : !fir.heap<!fir.array<42xi32>>
  return
^bb2:
  fir.freemem %0 : !fir.heap<!fir.array<42xi32>>
  return
}
// CHECK:      func.func @returns(%[[COND:.*]]: i1) {
// CHECK-NEXT:   %[[ALLOC:.*]] = fir.alloca !fir.array<42xi32>
// CHECK-NEXT:   cf.cond_br %[[COND]], ^bb1, ^bb2
// CHECK-NEXT: ^bb1:
// CHECK-NEXT:   return
// CHECK-NEXT: ^bb2:
// CHECK-NEXT:   return
// CHECK-NEXT: }

// Check multiple returns, where the memory is not freed on one branch
func.func @returns2(%arg0: i1) {
  %0 = fir.allocmem !fir.array<42xi32>
  cf.cond_br %arg0, ^bb1, ^bb2
^bb1:
  fir.freemem %0 : !fir.heap<!fir.array<42xi32>>
  return
^bb2:
  return
}
// CHECK:      func.func @returns2(%[[COND:.*]]: i1) {
// CHECK-NEXT:   %[[ALLOC:.*]] = fir.allocmem !fir.array<42xi32>
// CHECK-NEXT:   cf.cond_br %[[COND]], ^bb1, ^bb2
// CHECK-NEXT: ^bb1:
// CHECK-NEXT:   fir.freemem %[[ALLOC]] : !fir.heap<!fir.array<42xi32>>
// CHECK-NEXT:   return
// CHECK-NEXT: ^bb2:
// CHECK-NEXT:   return
// CHECK-NEXT: }

// Check allocations are not moved outside of an omp region
func.func @omp_placement1() {
  omp.sections {
    omp.section {
      %mem = fir.allocmem !fir.array<42xi32>
      fir.freemem %mem : !fir.heap<!fir.array<42xi32>>
      omp.terminator
    }
    omp.terminator
  }
  return
}
// CHECK:      func.func @omp_placement1() {
// CHECK-NEXT:   %[[MEM:.*]] = fir.alloca !fir.array<42xi32>
// CHECK-NEXT:   %[[MEM_CONV:.*]] = fir.convert %[[MEM]] : (!fir.ref<!fir.array<42xi32>>) -> !fir.heap<!fir.array<42xi32>>
// CHECK-NEXT:   omp.sections {
// CHECK-NEXT:     omp.section {
// CHECK-NEXT:       omp.terminator
// CHECK-NEXT:     }
// CHECK-NEXT:     omp.terminator
// CHECK-NEXT:   }
// CHECK-NEXT:   return
// CHECK-NEXT: }

// function terminated by stop statement
func.func @stop_terminator() {
  %0 = fir.allocmem !fir.array<42xi32>
  fir.freemem %0 : !fir.heap<!fir.array<42xi32>>
  %c0_i32 = arith.constant 0 : i32
  %false = arith.constant false
  fir.call @_FortranAStopStatement(%c0_i32, %false, %false) : (i32, i1, i1) -> ()
  fir.unreachable
}
// CHECK: func.func @stop_terminator() {
// CHECK-NEXT: fir.alloca !fir.array<42xi32>
// CHECK-NEXT:  %[[ZERO:.*]] = arith.constant 0 : i32
// CHECK-NEXT:  %[[FALSE:.*]] = arith.constant false
// CHECK-NEXT:  fir.call @_FortranAStopStatement(%[[ZERO]], %[[FALSE]], %[[FALSE]]) : (i32, i1, i1) -> ()
// CHECK-NEXT:  fir.unreachable
// CHECK-NEXT: }


// check that stack allocations that use fir.declare which must be placed in loops
// use stacksave
func.func @placement_loop_declare() {
  %c1 = arith.constant 1 : index
  %c1_i32 = fir.convert %c1 : (index) -> i32
  %c2 = arith.constant 2 : index
  %c10 = arith.constant 10 : index
  %0:2 = fir.do_loop %arg0 = %c1 to %c10 step %c1 iter_args(%arg1 = %c1_i32) -> (index, i32) {
    %3 = arith.addi %c1, %c2 : index
    // operand is now available
    %4 = fir.allocmem !fir.array<?xi32>, %3
    %shape = fir.shape %3 : (index) -> !fir.shape<1>
    %5 = fir.declare %4(%shape) {uniq_name = "temp"} : (!fir.heap<!fir.array<?xi32>>, !fir.shape<1>) -> !fir.heap<!fir.array<?xi32>>
    // ...
    fir.freemem %5 : !fir.heap<!fir.array<?xi32>>
    fir.result %3, %c1_i32 : index, i32
  }
  return
}
// CHECK:      func.func @placement_loop_declare() {
// CHECK-NEXT:   %[[C1:.*]] = arith.constant 1 : index
// CHECK-NEXT:   %[[C1_I32:.*]] = fir.convert %[[C1]] : (index) -> i32
// CHECK-NEXT:   %[[C2:.*]] = arith.constant 2 : index
// CHECK-NEXT:   %[[C10:.*]] = arith.constant 10 : index
// CHECK-NEXT:   fir.do_loop
// CHECK-NEXT:     %[[SUM:.*]] = arith.addi %[[C1]], %[[C2]] : index
// CHECK-NEXT:     %[[SP:.*]] = llvm.intr.stacksave : !llvm.ptr
// CHECK-NEXT:     %[[MEM:.*]] = fir.alloca !fir.array<?xi32>, %[[SUM]]
// CHECK:          llvm.intr.stackrestore %[[SP]] : !llvm.ptr
// CHECK-NEXT:     fir.result
// CHECK-NEXT:   }
// CHECK-NEXT:   return
// CHECK-NEXT: }

// Can we look through fir.convert and fir.declare?
func.func @lookthrough() {
  %0 = fir.allocmem !fir.array<42xi32>
  %c42 = arith.constant 42 : index
  %shape = fir.shape %c42 : (index) -> !fir.shape<1>
  %1 = fir.declare %0(%shape) {uniq_name = "name"} : (!fir.heap<!fir.array<42xi32>>, !fir.shape<1>) -> !fir.heap<!fir.array<42xi32>>
  %2 = fir.convert %1 : (!fir.heap<!fir.array<42xi32>>) -> !fir.ref<!fir.array<42xi32>>
  // use the ref so the converts aren't folded
  %3 = fir.load %2 : !fir.ref<!fir.array<42xi32>>
  %4 = fir.convert %2 : (!fir.ref<!fir.array<42xi32>>) -> !fir.heap<!fir.array<42xi32>>
  fir.freemem %4 : !fir.heap<!fir.array<42xi32>>
  return
}
// CHECK: func.func @lookthrough() {
// CHECK:     fir.alloca !fir.array<42xi32>
// CHECK-NOT: fir.freemem

// StackArrays is better to find fir.freemem ops corresponding to fir.allocmem
// using the same look through mechanism as during the allocation analysis,
// looking through fir.convert and fir.declare.
func.func @finding_freemem_in_block() {
  %c0 = arith.constant 0 : index
  %c10_i32 = arith.constant 10 : i32
  %c1_i32 = arith.constant 1 : i32
  %0 = fir.alloca i32 {bindc_name = "k", uniq_name = "k"}
  %1 = fir.declare %0 {uniq_name = "k"} : (!fir.ref<i32>) -> !fir.ref<i32>
  fir.store %c1_i32 to %1 : !fir.ref<i32>
  cf.br ^bb1
^bb1:  // 2 preds: ^bb0, ^bb2
  %2 = fir.load %1 : !fir.ref<i32>
  %3 = arith.cmpi sle, %2, %c10_i32 : i32
  cf.cond_br %3, ^bb2, ^bb3
^bb2:  // pred: ^bb1
  %4 = fir.declare %1 {fortran_attrs = #fir.var_attrs<intent_in>, uniq_name = "x"} : (!fir.ref<i32>) -> !fir.ref<i32>
  %5 = fir.load %4 : !fir.ref<i32>
  %6 = fir.convert %5 : (i32) -> index
  %7 = arith.cmpi sgt, %6, %c0 : index
  %8 = arith.select %7, %6, %c0 : index
  %9 = fir.shape %8 : (index) -> !fir.shape<1>
  %10 = fir.allocmem !fir.array<?xi32>, %8 {bindc_name = ".tmp.expr_result", uniq_name = ""}
  %11 = fir.convert %10 : (!fir.heap<!fir.array<?xi32>>) -> !fir.ref<!fir.array<?xi32>>
  %12 = fir.declare %11(%9) {uniq_name = ".tmp.expr_result"} : (!fir.ref<!fir.array<?xi32>>, !fir.shape<1>) -> !fir.ref<!fir.array<?xi32>>
  %13 = fir.embox %12(%9) : (!fir.ref<!fir.array<?xi32>>, !fir.shape<1>) -> !fir.box<!fir.array<?xi32>>
  %14 = fir.call @_QPfunc(%1) fastmath<fast> : (!fir.ref<i32>) -> !fir.array<?xi32>
  fir.save_result %14 to %12(%9) : !fir.array<?xi32>, !fir.ref<!fir.array<?xi32>>, !fir.shape<1>
  fir.call @_QPsub(%13) fastmath<fast> : (!fir.box<!fir.array<?xi32>>) -> ()
  %15 = fir.convert %12 : (!fir.ref<!fir.array<?xi32>>) -> !fir.heap<!fir.array<?xi32>>
  fir.freemem %15 : !fir.heap<!fir.array<?xi32>>
  %16 = fir.load %1 : !fir.ref<i32>
  %17 = arith.addi %16, %c1_i32 : i32
  fir.store %17 to %1 : !fir.ref<i32>
  cf.br ^bb1
^bb3:  // pred: ^bb1
  return
}
// CHECK: func.func @finding_freemem_in_block() {
// CHECK:     fir.alloca !fir.array<?xi32>
// CHECK-NOT: fir.freemem
