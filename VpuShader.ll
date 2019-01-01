; ModuleID = 'VpuShader.bc'
source_filename = "llvm-link"
target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i686-pc-windows-msvc19.16.27025"

%struct.VpuThreadLocalStorage = type { i32, [4 x %struct.VpuResourceDescriptor] }
%struct.VpuResourceDescriptor = type { i8*, i32 }
%dx.types.Handle = type { i8* }
%dx.types.ResRet.i32 = type { i32, i32, i32, i32, i32 }
%dx.types.ResRet.f32 = type { float, float, float, float, i32 }
%"class.RWStructuredBuffer<BufType>" = type { %struct.BufType }
%struct.BufType = type { i32, float }

@g_tls = common dso_local global %struct.VpuThreadLocalStorage zeroinitializer, align 4

define void @main() {
entry:
  %BufferOut_UAV_structbuf = call %dx.types.Handle @dx.op.createHandle(i32 57, i8 1, i32 2, i32 2, i1 false)
  %Buffer1_UAV_structbuf = call %dx.types.Handle @dx.op.createHandle(i32 57, i8 1, i32 1, i32 1, i1 false)
  %Buffer0_UAV_structbuf = call %dx.types.Handle @dx.op.createHandle(i32 57, i8 1, i32 0, i32 0, i1 false)
  %0 = call i32 @dx.op.threadId.i32(i32 93, i32 0)
  %1 = call %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32 68, %dx.types.Handle %Buffer0_UAV_structbuf, i32 %0, i32 0)
  %2 = extractvalue %dx.types.ResRet.i32 %1, 0
  %3 = call %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32 68, %dx.types.Handle %Buffer1_UAV_structbuf, i32 %0, i32 0)
  %4 = extractvalue %dx.types.ResRet.i32 %3, 0
  %add = add nsw i32 %4, %2
  call void @dx.op.bufferStore.i32(i32 69, %dx.types.Handle %BufferOut_UAV_structbuf, i32 %0, i32 0, i32 %add, i32 undef, i32 undef, i32 undef, i8 1)
  %5 = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle %Buffer0_UAV_structbuf, i32 %0, i32 4)
  %6 = extractvalue %dx.types.ResRet.f32 %5, 0
  %7 = call %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32 68, %dx.types.Handle %Buffer1_UAV_structbuf, i32 %0, i32 4)
  %8 = extractvalue %dx.types.ResRet.f32 %7, 0
  %add8 = fadd fast float %8, %6
  call void @dx.op.bufferStore.f32(i32 69, %dx.types.Handle %BufferOut_UAV_structbuf, i32 %0, i32 4, float %add8, float undef, float undef, float undef, i8 1)
  ret void
}

; Function Attrs: nounwind readonly
declare %dx.types.Handle @dx.op.createHandle(i32, i8, i32, i32, i1) #0

; Function Attrs: nounwind readnone
declare i32 @dx.op.threadId.i32(i32, i32) #1

; Function Attrs: nounwind readonly
declare %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32, %dx.types.Handle, i32, i32) #0

; Function Attrs: nounwind
declare void @dx.op.bufferStore.i32(i32, %dx.types.Handle, i32, i32, i32, i32, i32, i32, i8) #2

; Function Attrs: nounwind readonly
declare %dx.types.ResRet.f32 @dx.op.bufferLoad.f32(i32, %dx.types.Handle, i32, i32) #0

; Function Attrs: nounwind
declare void @dx.op.bufferStore.f32(i32, %dx.types.Handle, i32, i32, float, float, float, float, i8) #2

; Function Attrs: noinline nounwind optnone
define dso_local i8* @memset(i8*, i32, i32) #3 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i8*, align 4
  %7 = alloca i8*, align 4
  store i32 %2, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  store i8* %0, i8** %6, align 4
  %8 = load i8*, i8** %6, align 4
  store i8* %8, i8** %7, align 4
  br label %9

; <label>:9:                                      ; preds = %13, %3
  %10 = load i32, i32* %4, align 4
  %11 = add i32 %10, -1
  store i32 %11, i32* %4, align 4
  %12 = icmp ugt i32 %10, 0
  br i1 %12, label %13, label %18

; <label>:13:                                     ; preds = %9
  %14 = load i32, i32* %5, align 4
  %15 = trunc i32 %14 to i8
  %16 = load i8*, i8** %7, align 4
  %17 = getelementptr inbounds i8, i8* %16, i32 1
  store i8* %17, i8** %7, align 4
  store i8 %15, i8* %16, align 1
  br label %9

; <label>:18:                                     ; preds = %9
  %19 = load i8*, i8** %6, align 4
  ret i8* %19
}

; Function Attrs: noinline nounwind optnone
define dso_local %struct.VpuResourceDescriptor* @dx_op_createHandle(i32, i8 signext, i32, i32, i8 signext) #3 {
  %6 = alloca i8, align 1
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i8, align 1
  %10 = alloca i32, align 4
  %11 = alloca %struct.VpuResourceDescriptor*, align 4
  store i8 %4, i8* %6, align 1
  store i32 %3, i32* %7, align 4
  store i32 %2, i32* %8, align 4
  store i8 %1, i8* %9, align 1
  store i32 %0, i32* %10, align 4
  %12 = load i32, i32* %7, align 4
  %13 = getelementptr inbounds [4 x %struct.VpuResourceDescriptor], [4 x %struct.VpuResourceDescriptor]* getelementptr inbounds (%struct.VpuThreadLocalStorage, %struct.VpuThreadLocalStorage* @g_tls, i32 0, i32 1), i32 0, i32 %12
  store %struct.VpuResourceDescriptor* %13, %struct.VpuResourceDescriptor** %11, align 4
  %14 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %11, align 4
  ret %struct.VpuResourceDescriptor* %14
}

; Function Attrs: noinline nounwind optnone
define dso_local void @dx_op_bufferLoad_f32(%dx.types.ResRet.f32* noalias sret, i32, %struct.VpuResourceDescriptor*, i32, i32) #3 {
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca %struct.VpuResourceDescriptor*, align 4
  %9 = alloca i32, align 4
  store i32 %4, i32* %6, align 4
  store i32 %3, i32* %7, align 4
  store %struct.VpuResourceDescriptor* %2, %struct.VpuResourceDescriptor** %8, align 4
  store i32 %1, i32* %9, align 4
  %10 = bitcast %dx.types.ResRet.f32* %0 to i8*
  call void @llvm.memset.p0i8.i32(i8* align 4 %10, i8 0, i32 20, i1 false)
  %11 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %8, align 4
  %12 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %11, i32 0, i32 0
  %13 = load i8*, i8** %12, align 4
  %14 = load i32, i32* %7, align 4
  %15 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %8, align 4
  %16 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %15, i32 0, i32 1
  %17 = load i32, i32* %16, align 4
  %18 = mul nsw i32 %14, %17
  %19 = getelementptr inbounds i8, i8* %13, i32 %18
  %20 = load i32, i32* %6, align 4
  %21 = getelementptr inbounds i8, i8* %19, i32 %20
  %22 = bitcast i8* %21 to float*
  %23 = load float, float* %22, align 4
  %24 = getelementptr inbounds %dx.types.ResRet.f32, %dx.types.ResRet.f32* %0, i32 0, i32 0
  store float %23, float* %24, align 4
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i32(i8* nocapture writeonly, i8, i32, i1) #4

; Function Attrs: noinline nounwind optnone
define dso_local void @dx_op_bufferLoad_i32(%dx.types.ResRet.i32* noalias sret, i32, %struct.VpuResourceDescriptor*, i32, i32) #3 {
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca %struct.VpuResourceDescriptor*, align 4
  %9 = alloca i32, align 4
  store i32 %4, i32* %6, align 4
  store i32 %3, i32* %7, align 4
  store %struct.VpuResourceDescriptor* %2, %struct.VpuResourceDescriptor** %8, align 4
  store i32 %1, i32* %9, align 4
  %10 = bitcast %dx.types.ResRet.i32* %0 to i8*
  call void @llvm.memset.p0i8.i32(i8* align 4 %10, i8 0, i32 20, i1 false)
  %11 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %8, align 4
  %12 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %11, i32 0, i32 0
  %13 = load i8*, i8** %12, align 4
  %14 = load i32, i32* %7, align 4
  %15 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %8, align 4
  %16 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %15, i32 0, i32 1
  %17 = load i32, i32* %16, align 4
  %18 = mul nsw i32 %14, %17
  %19 = getelementptr inbounds i8, i8* %13, i32 %18
  %20 = load i32, i32* %6, align 4
  %21 = getelementptr inbounds i8, i8* %19, i32 %20
  %22 = bitcast i8* %21 to i32*
  %23 = load i32, i32* %22, align 4
  %24 = getelementptr inbounds %dx.types.ResRet.i32, %dx.types.ResRet.i32* %0, i32 0, i32 0
  store i32 %23, i32* %24, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define dso_local void @dx_op_bufferStore_f32(i32, %struct.VpuResourceDescriptor*, i32, i32, float, float, float, float, i8 signext) #3 {
  %10 = alloca i8, align 1
  %11 = alloca float, align 4
  %12 = alloca float, align 4
  %13 = alloca float, align 4
  %14 = alloca float, align 4
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca %struct.VpuResourceDescriptor*, align 4
  %18 = alloca i32, align 4
  store i8 %8, i8* %10, align 1
  store float %7, float* %11, align 4
  store float %6, float* %12, align 4
  store float %5, float* %13, align 4
  store float %4, float* %14, align 4
  store i32 %3, i32* %15, align 4
  store i32 %2, i32* %16, align 4
  store %struct.VpuResourceDescriptor* %1, %struct.VpuResourceDescriptor** %17, align 4
  store i32 %0, i32* %18, align 4
  %19 = load float, float* %14, align 4
  %20 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %17, align 4
  %21 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %20, i32 0, i32 0
  %22 = load i8*, i8** %21, align 4
  %23 = load i32, i32* %16, align 4
  %24 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %17, align 4
  %25 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %24, i32 0, i32 1
  %26 = load i32, i32* %25, align 4
  %27 = mul nsw i32 %23, %26
  %28 = getelementptr inbounds i8, i8* %22, i32 %27
  %29 = load i32, i32* %15, align 4
  %30 = getelementptr inbounds i8, i8* %28, i32 %29
  %31 = bitcast i8* %30 to float*
  store float %19, float* %31, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define dso_local void @dx_op_bufferStore_i32(i32, %struct.VpuResourceDescriptor*, i32, i32, i32, i32, i32, i32, i32) #3 {
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca %struct.VpuResourceDescriptor*, align 4
  %18 = alloca i32, align 4
  store i32 %8, i32* %10, align 4
  store i32 %7, i32* %11, align 4
  store i32 %6, i32* %12, align 4
  store i32 %5, i32* %13, align 4
  store i32 %4, i32* %14, align 4
  store i32 %3, i32* %15, align 4
  store i32 %2, i32* %16, align 4
  store %struct.VpuResourceDescriptor* %1, %struct.VpuResourceDescriptor** %17, align 4
  store i32 %0, i32* %18, align 4
  %19 = load i32, i32* %14, align 4
  %20 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %17, align 4
  %21 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %20, i32 0, i32 0
  %22 = load i8*, i8** %21, align 4
  %23 = load i32, i32* %16, align 4
  %24 = load %struct.VpuResourceDescriptor*, %struct.VpuResourceDescriptor** %17, align 4
  %25 = getelementptr inbounds %struct.VpuResourceDescriptor, %struct.VpuResourceDescriptor* %24, i32 0, i32 1
  %26 = load i32, i32* %25, align 4
  %27 = mul nsw i32 %23, %26
  %28 = getelementptr inbounds i8, i8* %22, i32 %27
  %29 = load i32, i32* %15, align 4
  %30 = getelementptr inbounds i8, i8* %28, i32 %29
  %31 = bitcast i8* %30 to i32*
  store i32 %19, i32* %31, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone
define dso_local i32 @dx_op_threadId_i32(i32, i32) #3 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %1, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  %5 = load i32, i32* getelementptr inbounds (%struct.VpuThreadLocalStorage, %struct.VpuThreadLocalStorage* @g_tls, i32 0, i32 0), align 4
  ret i32 %5
}

attributes #0 = { nounwind readonly }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }
attributes #3 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="pentium4" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { argmemonly nounwind }

!llvm.ident = !{!0, !1}
!dx.version = !{!2}
!dx.valver = !{!3}
!dx.shaderModel = !{!4}
!dx.resources = !{!5}
!dx.typeAnnotations = !{!11, !17}
!dx.entryPoints = !{!21}
!llvm.module.flags = !{!24, !25}

!0 = !{!"clang version 3.7 (tags/RELEASE_370/final)"}
!1 = !{!"clang version 7.0.0 (tags/RELEASE_700/final)"}
!2 = !{i32 1, i32 0}
!3 = !{i32 1, i32 4}
!4 = !{!"cs", i32 6, i32 0}
!5 = !{null, !6, null, null}
!6 = !{!7, !9, !10}
!7 = !{i32 0, %"class.RWStructuredBuffer<BufType>"* undef, !"Buffer0", i32 0, i32 0, i32 1, i32 12, i1 false, i1 false, i1 false, !8}
!8 = !{i32 1, i32 8}
!9 = !{i32 1, %"class.RWStructuredBuffer<BufType>"* undef, !"Buffer1", i32 0, i32 1, i32 1, i32 12, i1 false, i1 false, i1 false, !8}
!10 = !{i32 2, %"class.RWStructuredBuffer<BufType>"* undef, !"BufferOut", i32 0, i32 2, i32 1, i32 12, i1 false, i1 false, i1 false, !8}
!11 = !{i32 0, %"class.RWStructuredBuffer<BufType>" undef, !12, %struct.BufType undef, !14}
!12 = !{i32 8, !13}
!13 = !{i32 6, !"h", i32 3, i32 0}
!14 = !{i32 8, !15, !16}
!15 = !{i32 6, !"i", i32 3, i32 0, i32 7, i32 4}
!16 = !{i32 6, !"f", i32 3, i32 4, i32 7, i32 9}
!17 = !{i32 1, void ()* @main, !18}
!18 = !{!19}
!19 = !{i32 0, !20, !20}
!20 = !{}
!21 = !{void ()* @main, !"main", null, !5, !22}
!22 = !{i32 0, i64 16, i32 4, !23}
!23 = !{i32 4, i32 1, i32 1}
!24 = !{i32 1, !"NumRegisterParameters", i32 0}
!25 = !{i32 1, !"wchar_size", i32 2}