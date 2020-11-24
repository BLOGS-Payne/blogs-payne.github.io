---
title: Golang切片-slice
tags: ["Go"]
categories:
- ["Go"]
date: 2020-11-21 22:10:19
author: Payne
---
在上篇数据类型-Array中写到**因为数组的长度是固定的并且数组长度属于类型的一部分**,所以数组有很多的局限性
<!--more-->
> ```go
> func arraySum(x [5]int) int{
>  sum := 0
>  for _, v := range x{
>      sum = sum + v
>  }
>  return sum
> }
> ```
>
> 这个求和函数只能接受`[5]int`类型，其他的都不支持。 再比如，
>
> ```go
> a := [5]int{1, 2, 3, 4, 5}
> ```
>
> 数组a中已经有五个元素了，我们不能再继续往数组a中添加新元素了。

## 切片的本质

切片的本质就是对底层数组的封装，它包含了三个信息：

- 底层数组的指针
- 切片的长度（len）
- 切片的容量（cap)

举个例子，现在有一个数组`a := [8]int{0, 1, 2, 3, 4, 5, 6, 7}`，切片`s1 := a[:5]`，相应示意图如下。

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkl8xaagu0j318e0l2abf.jpg)

切片`s2 := a[3:6]`，相应示意图如下：

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkl8xvn3bdj318e0l2q4b.jpg)

## 切片的定义

```go
// 初始化定义
// 基于var，var定义的时仅会声明，不会申请内存！！！
var 变量名 []类型
// make([]T, size, cap) make初始化分配内存
make([]类型, 切片中元素的数量, 切片的容量)

// 自定义
变量名 := []类型{值1，值2。。。}

// 示例
package main

import "fmt"

func main() {
  // var
	var s1 []int             //var定义的时仅会声明，不会申请内存
	fmt.Println(s1)          // []
	fmt.Println(s1 == nil)   // true
	s1 = []int{1, 2, 3, 4, 5}
	fmt.Println(s1[0:2])     // [1 2]
	// make
	s2 := make([]int, 4, 6)   // make初始化分配内存
	fmt.Println(s2)           // [0 0 0 0]
	fmt.Println(s2 == nil)    // false
	s2 = []int{1, 2, 3, 4}
	fmt.Println(s2[0:2])       // [1 2]
}
```

### var 声明切片

```go
package main

import "fmt"

func main() {
	// 声明切片类型
	var s1 []string              //声明一个字符串切片
  var s2 = []int{}             //声明一个整型切片并初始化(不规范写法，注意！！！)
	var s3 = []bool{false, true} //声明一个布尔切片并初始化
	var s4 = []bool{false, true} //声明一个布尔切片并初始化
	fmt.Println(s1)              //[]
	fmt.Println(s2)              //[]
	fmt.Println(s3)              //[false true]
	fmt.Println(s4)              //[false true]
	fmt.Println(s1 == nil)       //true
	fmt.Println(s2 == nil)       //false
	fmt.Println(s3 == nil)       //false
	fmt.Println(s4 == nil)       //false
	// fmt.Println(s3 == s4)       //切片是引用类型，不支持直接比较，只能和nil比较
}
```

### Make 初始化切片

```go
package main

import "fmt"

func main() {
	// make 初始化切片
	s1 := make([]int, 4, 6)        
	s2 := make([]string, 4, 6)     
	s3 := make([]bool,2, 4)        
	fmt.Println(s1)                // [0 0 0 0]
	fmt.Println(s2)                // [       ]
	fmt.Println(s3)                // [false false]
	fmt.Println(s1 == nil)         // false
	fmt.Println(s2 == nil)         // false
	fmt.Println(s3 == nil)         // false
	//fmt.Println(s2 == s3)        // 切片是引用类型，不支持直接比较，只能和nil比较
}
```

## 判断切片是否为空

要检查切片是否为空，请始终使用`len(s) == 0`来判断，而不应该使用`s == nil`来判断。

### 切片不能直接比较

切片之间是不能比较的，我们不能使用`==`操作符来判断两个切片是否含有全部相等元素。 切片唯一合法的比较操作是和`nil`比较。 一个`nil`值的切片并没有底层数组，一个`nil`值的切片的长度和容量都是0。但是我们不能说一个长度和容量都是0的切片一定是`nil`，例如下面的示例：

```go
var s1 []int         //len(s1)=0;cap(s1)=0;s1==nil
s2 := []int{}        //len(s2)=0;cap(s2)=0;s2!=nil
s3 := make([]int, 0) //len(s3)=0;cap(s3)=0;s3!=nil
```

所以要判断一个切片是否是空的，要是用`len(s) == 0`来判断，不应该使用`s == nil`来判断。

## 切片的赋值拷贝

下面的代码中演示了拷贝前后两个变量共享底层数组，对一个切片的修改会影响另一个切片的内容，这点需要特别注意。

```go
package main

import "fmt"

func main() {
	// 切片的赋值拷贝
	s1 := make([]int, 2, 4)
	s2 := s1
	s1[0] = 80
	s2[1] = 100
	fmt.Println(s1)    // [80 100]
	fmt.Println(s2)    // [80 100]
}
```

## 切片遍历

切片的遍历方式和数组(Array)是一致的，支持索引遍历和`for range`遍历。

```go
func main() {
	s := []int{1, 3, 5}

	for i := 0; i < len(s); i++ {
		fmt.Println(i, s[i])
	}

	for index, value := range s {
		fmt.Println(index, value)
	}
}
```

## 切片添加元素

Go语言的内建函数`append()`可以为切片动态添加元素。 可以一次添加一个元素，可以添加多个元素，也可以添加另一个切片中的元素（后面加…）。

```
目标变量 = append(需被加入切片的变量名， 需追加的常量或者切片的变量名)
```



```go
func main(){
	var s []int
  // 添加单个元素
	s = append(s, 1)        // [1]
  // 添加多个元素
	s = append(s, 2, 3, 4)  // [1 2 3 4]
	s2 := []int{5, 6, 7}  
  // 添加切片
	s = append(s, s2...)    // [1 2 3 4 5 6 7]
}
```

**注意：**通过var声明的零值切片，在`append()`函数中可直接使用，无需初始化。

```go
// 可以这样做，但没必要
	s := []int{} // 没有必要初始化
	s = append(s, 1, 2, 3, 4, 5, 6)
	fmt.Println(s)		// 1,2,3,4,5,6

// 错误写法
	var s = make([]int) 
	s = append(s, 1, 2, 3)
```

## 切片底层内存原理探究

### 引入

> 每个切片会指向一个底层数组，这个数组的容量够用就添加新增元素。当底层数组不能容纳新增的元素时，切片就会自动按照一定的策略进行“扩容”，此时该切片指向的底层数组就会更换。“扩容”操作往往发生在`append()`函数调用时，所以我们通常都需要用原变量接收append函数的返回值。
>
> ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gklp4pox1sj30t608875i.jpg)
>
> 从上面的结果可以看出：
>
> 1. `append()`函数将元素追加到切片的最后并返回该切片。
> 2. 切片numSlice的容量按照1，2，4，8，16这样的规则自动进行扩容，每次扩容后都是扩容前的2倍。



### 源码解读

`$GOROOT/src/runtime/slice.go`

```go
// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package runtime

import (
	"runtime/internal/math"
	"runtime/internal/sys"
	"unsafe"
)
// 自定义类型定义了一个全新的类型。基于内置的基本类型定义，也可以通过struct定义

// slice是一种新类型，同时也包含了struct所具有的特性
type slice struct { // 自定义类型名为slice，struct类型。
	array unsafe.Pointer
	len   int
	cap   int
}

// A notInHeapSlice is a slice backed by go:notinheap memory.
// notInHeapSlice是go：notinheap内存支持的切片
type notInHeapSlice struct {
	array *notInHeap
	len   int
	cap   int
}

func panicmakeslicelen() {
	panic(errorString("makeslice: len out of range"))
}

func panicmakeslicecap() {
	panic(errorString("makeslice: cap out of range"))
}

// makeslicecopy allocates a slice of "tolen" elements of type "et",
// then copies "fromlen" elements of type "et" into that new allocation from "from".
// makeslicecopy会分配一片类型为“ et”的“ tolen”元素，然后将类型为“ et”的“ fromlen”元素复制到“ from”的新分配中。
func makeslicecopy(et *_type, tolen int, fromlen int, from unsafe.Pointer) unsafe.Pointer {
	var tomem, copymem uintptr
	if uintptr(tolen) > uintptr(fromlen) {
		var overflow bool
		tomem, overflow = math.MulUintptr(et.size, uintptr(tolen))
		if overflow || tomem > maxAlloc || tolen < 0 {
			panicmakeslicelen()
		}
		copymem = et.size * uintptr(fromlen)
	} else {
		// fromlen is a known good length providing and equal or greater than tolen,
		// thereby making tolen a good slice length too as from and to slices have the
		// same element width.
    // fromlen是已知的良好长度，提供并等于或大于tolen，因此也使tolen具有良好的切片长度，因为from和to切片具有//相同的元素宽度。
		tomem = et.size * uintptr(tolen)
		copymem = tomem
	}

	var to unsafe.Pointer
	if et.ptrdata == 0 {
		to = mallocgc(tomem, nil, false)
		if copymem < tomem {
			memclrNoHeapPointers(add(to, copymem), tomem-copymem)
		}
	} else {
		// Note: can't use rawmem (which avoids zeroing of memory), because then GC can scan uninitialized memory.
    // 注意：不能使用rawmem（这样可以避免内存清零），因为GC可以扫描未初始化的内存。
		to = mallocgc(tomem, et, true)
		if copymem > 0 && writeBarrier.enabled {
			// Only shade the pointers in old.array since we know the destination slice to
			// only contains nil pointers because it has been cleared during alloc.
      //因为我们知道到//的目标切片仅包含nil指针，所以仅在old.array中隐藏了指针，因为在分配过程中已将其清除。
			bulkBarrierPreWriteSrcOnly(uintptr(to), uintptr(from), copymem)
		}
	}

	if raceenabled {
		callerpc := getcallerpc()
		pc := funcPC(makeslicecopy)
		racereadrangepc(from, copymem, callerpc, pc)
	}
	if msanenabled {
		msanread(from, copymem)
	}

	memmove(to, from, copymem)

	return to
}

func makeslice(et *_type, len, cap int) unsafe.Pointer {
	mem, overflow := math.MulUintptr(et.size, uintptr(cap))
	if overflow || mem > maxAlloc || len < 0 || len > cap {
		// NOTE: Produce a 'len out of range' error instead of a
		// 'cap out of range' error when someone does make([]T, bignumber).
		// 'cap out of range' is true too, but since the cap is only being
		// supplied implicitly, saying len is clearer.
		// See golang.org/issue/4085.
    ////注意：当有人进行make（[] T，bignumber）时，产生一个'len out of range'错误，而不是一个'cap cap out range'错误。 “上限超出范围”也是正确的，但是由于上限是隐式提供的，因此说len更清楚。 参见golang.org/issue/4085。
		mem, overflow := math.MulUintptr(et.size, uintptr(len))
		if overflow || mem > maxAlloc || len < 0 {
			panicmakeslicelen()
		}
		panicmakeslicecap()
	}

	return mallocgc(mem, et, true)
}

func makeslice64(et *_type, len64, cap64 int64) unsafe.Pointer {
	len := int(len64)
	if int64(len) != len64 {
		panicmakeslicelen()
	}

	cap := int(cap64)
	if int64(cap) != cap64 {
		panicmakeslicecap()
	}

	return makeslice(et, len, cap)
}

// growslice handles slice growth during append.
// It is passed the slice element type, the old slice, and the desired new minimum capacity,
// and it returns a new slice with at least that capacity, with the old data
// copied into it.
// The new slice's length is set to the old slice's length,
// NOT to the new requested capacity.
// This is for codegen convenience. The old slice's length is used immediately
// to calculate where to write new values during an append.
// TODO: When the old backend is gone, reconsider this decision.
// The SSA backend might prefer the new length or to return only ptr/cap and save stack space.
func growslice(et *_type, old slice, cap int) slice {
	if raceenabled {
		callerpc := getcallerpc()
		racereadrangepc(old.array, uintptr(old.len*int(et.size)), callerpc, funcPC(growslice))
	}
	if msanenabled {
		msanread(old.array, uintptr(old.len*int(et.size)))
	}

	if cap < old.cap {
		panic(errorString("growslice: cap out of range"))
	}

	if et.size == 0 {
		// append should not create a slice with nil pointer but non-zero len.
		// We assume that append doesn't need to preserve old.array in this case.
		return slice{unsafe.Pointer(&zerobase), old.len, cap}
	}

	newcap := old.cap
	doublecap := newcap + newcap
	if cap > doublecap {
		newcap = cap
	} else {
		if old.len < 1024 {
			newcap = doublecap
		} else {
			// Check 0 < newcap to detect overflow
			// and prevent an infinite loop.
			for 0 < newcap && newcap < cap {
				newcap += newcap / 4
			}
			// Set newcap to the requested cap when
			// the newcap calculation overflowed.
			if newcap <= 0 {
				newcap = cap
			}
		}
	}

	var overflow bool
	var lenmem, newlenmem, capmem uintptr
	// Specialize for common values of et.size.
	// For 1 we don't need any division/multiplication.
	// For sys.PtrSize, compiler will optimize division/multiplication into a shift by a constant.
	// For powers of 2, use a variable shift.
	switch {
	case et.size == 1:
		lenmem = uintptr(old.len)
		newlenmem = uintptr(cap)
		capmem = roundupsize(uintptr(newcap))
		overflow = uintptr(newcap) > maxAlloc
		newcap = int(capmem)
	case et.size == sys.PtrSize:
		lenmem = uintptr(old.len) * sys.PtrSize
		newlenmem = uintptr(cap) * sys.PtrSize
		capmem = roundupsize(uintptr(newcap) * sys.PtrSize)
		overflow = uintptr(newcap) > maxAlloc/sys.PtrSize
		newcap = int(capmem / sys.PtrSize)
	case isPowerOfTwo(et.size):
		var shift uintptr
		if sys.PtrSize == 8 {
			// Mask shift for better code generation.
			shift = uintptr(sys.Ctz64(uint64(et.size))) & 63
		} else {
			shift = uintptr(sys.Ctz32(uint32(et.size))) & 31
		}
		lenmem = uintptr(old.len) << shift
		newlenmem = uintptr(cap) << shift
		capmem = roundupsize(uintptr(newcap) << shift)
		overflow = uintptr(newcap) > (maxAlloc >> shift)
		newcap = int(capmem >> shift)
	default:
		lenmem = uintptr(old.len) * et.size
		newlenmem = uintptr(cap) * et.size
		capmem, overflow = math.MulUintptr(et.size, uintptr(newcap))
		capmem = roundupsize(capmem)
		newcap = int(capmem / et.size)
	}

	// The check of overflow in addition to capmem > maxAlloc is needed
	// to prevent an overflow which can be used to trigger a segfault
	// on 32bit architectures with this example program:
	//
	// type T [1<<27 + 1]int64
	//
	// var d T
	// var s []T
	//
	// func main() {
	//   s = append(s, d, d, d, d)
	//   print(len(s), "\n")
	// }
	if overflow || capmem > maxAlloc {
		panic(errorString("growslice: cap out of range"))
	}

	var p unsafe.Pointer
	if et.ptrdata == 0 {
		p = mallocgc(capmem, nil, false)
		// The append() that calls growslice is going to overwrite from old.len to cap (which will be the new length).
		// Only clear the part that will not be overwritten.
		memclrNoHeapPointers(add(p, newlenmem), capmem-newlenmem)
	} else {
		// Note: can't use rawmem (which avoids zeroing of memory), because then GC can scan uninitialized memory.
		p = mallocgc(capmem, et, true)
		if lenmem > 0 && writeBarrier.enabled {
			// Only shade the pointers in old.array since we know the destination slice p
			// only contains nil pointers because it has been cleared during alloc.
			bulkBarrierPreWriteSrcOnly(uintptr(p), uintptr(old.array), lenmem-et.size+et.ptrdata)
		}
	}
	memmove(p, old.array, lenmem)

	return slice{p, old.len, newcap}
}

func isPowerOfTwo(x uintptr) bool {
	return x&(x-1) == 0
}

func slicecopy(toPtr unsafe.Pointer, toLen int, fmPtr unsafe.Pointer, fmLen int, width uintptr) int {
	if fmLen == 0 || toLen == 0 {
		return 0
	}

	n := fmLen
	if toLen < n {
		n = toLen
	}

	if width == 0 {
		return n
	}

	if raceenabled {
		callerpc := getcallerpc()
		pc := funcPC(slicecopy)
		racereadrangepc(fmPtr, uintptr(n*int(width)), callerpc, pc)
		racewriterangepc(toPtr, uintptr(n*int(width)), callerpc, pc)
	}
	if msanenabled {
		msanread(fmPtr, uintptr(n*int(width)))
		msanwrite(toPtr, uintptr(n*int(width)))
	}

	size := uintptr(n) * width
	if size == 1 { // common case worth about 2x to do here
		// TODO: is this still worth it with new memmove impl?
		*(*byte)(toPtr) = *(*byte)(fmPtr) // known to be a byte pointer
	} else {
		memmove(toPtr, fmPtr, size)
	}
	return n
}

func slicestringcopy(toPtr *byte, toLen int, fm string) int {
	if len(fm) == 0 || toLen == 0 {
		return 0
	}

	n := len(fm)
	if toLen < n {
		n = toLen
	}

	if raceenabled {
		callerpc := getcallerpc()
		pc := funcPC(slicestringcopy)
		racewriterangepc(unsafe.Pointer(toPtr), uintptr(n), callerpc, pc)
	}
	if msanenabled {
		msanwrite(unsafe.Pointer(toPtr), uintptr(n))
	}

	memmove(unsafe.Pointer(toPtr), stringStructOf(&fm).str, uintptr(n))
	return n
}

```

内存分配部分，重点部分

```go
	newcap := old.cap
	doublecap := newcap + newcap
	if cap > doublecap {
		newcap = cap
	} else {
		if old.len < 1024 {
			newcap = doublecap
		} else {
			// Check 0 < newcap to detect overflow
			// and prevent an infinite loop.
			for 0 < newcap && newcap < cap {
				newcap += newcap / 4
			}
			// Set newcap to the requested cap when
			// the newcap calculation overflowed.
			if newcap <= 0 {
				newcap = cap
			}
		}
	}
```

> - 首先判断，如果新申请容量（cap）大于2倍的旧容量（old.cap），最终容量（newcap）就是新申请的容量（cap）。
> - 否则判断，如果旧切片的长度小于1024，则最终容量(newcap)就是旧容量(old.cap)的两倍，即（newcap=doublecap），
> - 否则判断，如果旧切片长度大于等于1024，则最终容量（newcap）从旧容量（old.cap）开始循环增加原来的1/4，即（newcap=old.cap,for {newcap += newcap/4}）直到最终容量（newcap）大于等于新申请的容量(cap)，即（newcap >= cap）
> - 如果最终容量（cap）计算值溢出，则最终容量（cap）就是新申请容量（cap）。
>
> 需要注意的是，切片扩容还会根据切片中元素的类型不同而做不同的处理，比如`int`和`string`类型的处理方式就不一样。

## 复制切片

```go
// 疑问
func main() {
	a := []int{1, 2, 3, 4, 5}
	b := a
	fmt.Println(a) //[1 2 3 4 5]
	fmt.Println(b) //[1 2 3 4 5]
	b[0] = 1000
	fmt.Println(a) //[1000 2 3 4 5]
	fmt.Println(b) //[1000 2 3 4 5]
}

// 缘由：由于切片是引用类型，所以a和b其实都指向了同一块内存地址。修改b的同时a的值也会发生变化。
```

Go语言内建的`copy()`函数可以迅速地将一个切片的数据复制到另外一个切片空间中，`copy()`函数的使用格式如下：

```go
copy(destSlice, srcSlice []T)
// 其中：
- srcSlice: 数据来源切片
- destSlice: 目标切片
```

示例如下

```go
func main() {
// copy()复制切片
	s1 := []int{1, 2, 3}
	s2 := make([]int, 5, 5)
	copy(s2, s1)     //使用copy()函数将切片a中的元素复制到切片s2
	fmt.Println(s1) //[1 2 3]
	fmt.Println(s2) // [1 2 3 0 0]
	s2[0] = 10
	fmt.Println(s1) //[1 2 3]
	fmt.Println(s2) //[10 2 3 0 0]
}
```

## 删除元素

Go语言中并没有删除切片元素的专用方法，我们可以使用切片本身的特性来删除元素。 代码如下：

```go
func main() {
	// 从切片中删除元素
	a := []int{30, 31, 32, 33, 34, 35, 36, 37}
	// 要删除索引为2的元素
	a = append(a[:2], a[3:]...)
	fmt.Println(a) //[30 31 33 34 35 36 37]
}
```

总结：要从切片a中删除索引为`index`的元素，操作方法是`a = append(a[:index], a[index+1:]...)`

## 总结及注意点

- 底层数组的指针、切片的长度（len）、切片的容量（cap)
- `var`与`make`基于var，var定义的时仅会声明，不会申请内存。make初始化会分配内存。其内容为初始值。(string: 空、int：0、bool：false、Array：var时为nil\make时为"[]"的内部有Len-1个0)
- 通过var声明的零值切片可以在`append()`函数直接使用，无需初始化。
- Append可以一次添加一个元素，可以添加多个元素，也可以添加另一个切片中的元素（后面需要加…）。
- 当内存小于1024时，每次扩宽两倍。当1024每次增加原本的1/4倍
- 要从切片a中删除索引为`index`的元素，操作方法是`a = append(a[:index], a[index+1:]...)`
