﻿#include "pch-cpp.hpp"

#ifndef _MSC_VER
# include <alloca.h>
#else
# include <malloc.h>
#endif


#include <limits>



struct Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87;
struct Dictionary_2_t403063CE4960B4F46C688912237C6A27E550FF55;
struct EventHandler_1_tE698654C3F437D97ABCCA3FD0AD8F86E776DC77A;
struct Func_1_tD59A12717D79BFB403BF973694B1BE5B85474BD1;
struct Predicate_1_t8342C85FF4E41CD1F7024AC0CDC3E5312A32CB12;
struct Predicate_1_t7F48518B008C1472339EEEBABA3DE203FE1F26ED;
struct DelegateU5BU5D_tC5AB7E8F745616680F337909D3A8E6C722CDF771;
struct Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07;
struct CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B;
struct ContextCallback_tE8AFBDBFCC040FDA8DA8C1EEFE9BD66B16BDA007;
struct Delegate_t;
struct DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E;
struct Lock_t529C04C831C120E5FFD6039EC3CB76F9956BCDD7;
struct MethodInfo_t;
struct StackGuard_tACE063A1B7374BDF4AD472DE4585D05AD8745352;
struct String_t;
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572;
struct TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0;
struct TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E;
struct UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC;
struct Void_t4861ACF8F4594C3437BB48B6E56783494B843915;
struct ContingentProperties_t3FA59480914505CEA917B1002EC675F29D0CB540;

IL2CPP_EXTERN_C Il2CppSequencePoint g_sequencePointsUnity_Services_Core[];
IL2CPP_EXTERN_C Il2CppSequencePoint g_sequencePointsUnity_Services_Core_Threading[];
IL2CPP_EXTERN_C RuntimeClass* CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* UnityThreadUtils_tCC1D0915CC9C90AEB5B27F2A9D791544FAC0DEBA_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C const RuntimeMethod* Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Send_m701390E8B2BC62F04BFC284B5A6A60C3CA8278E9_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Send_m91B4D5F642779F7886B18FDBB6ACAAB3CAE65DB6_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_m2A06D795FE85F4D5B5E0492FF45E0BD3379B2F46_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_mB7F687F4632DE34A0AF82D911BD507987CD59356_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m6A90E8351E6FD33374C3D7EAF7C7D74872E0A1B8_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m8918510A7586D876A98DC733B90FB534B228BE3F_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_get_IsRunningOnUnityThread_m264DB20EE6404E1C396E078FADE78F0C91CC7E1A_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtilsInternal__ctor_m9430BA50989685AA40935124D40A44F29156A3A2_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeType* UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC_0_0_0_var;
struct Delegate_t_marshaled_com;
struct Delegate_t_marshaled_pinvoke;


IL2CPP_EXTERN_C_BEGIN
IL2CPP_EXTERN_C_END

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
struct U3CModuleU3E_tC445F3DAD73003CEBF9FF7BF1C109B3025166895 
{
};
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572  : public RuntimeObject
{
	int32_t ___m_taskId;
	Delegate_t* ___m_action;
	RuntimeObject* ___m_stateObject;
	TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___m_taskScheduler;
	Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* ___m_parent;
	int32_t ___m_stateFlags;
	RuntimeObject* ___m_continuationObject;
	ContingentProperties_t3FA59480914505CEA917B1002EC675F29D0CB540* ___m_contingentProperties;
};
struct TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E  : public RuntimeObject
{
	int32_t ___m_taskSchedulerId;
};
struct UnityThreadUtils_tCC1D0915CC9C90AEB5B27F2A9D791544FAC0DEBA  : public RuntimeObject
{
};
struct UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC  : public RuntimeObject
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F  : public RuntimeObject
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F_marshaled_pinvoke
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F_marshaled_com
{
};
struct Boolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22 
{
	bool ___m_value;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED 
{
	CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B* ____source;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_marshaled_pinvoke
{
	CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B* ____source;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_marshaled_com
{
	CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B* ____source;
};
struct IntPtr_t 
{
	void* ___m_value;
};
struct Void_t4861ACF8F4594C3437BB48B6E56783494B843915 
{
	union
	{
		struct
		{
		};
		uint8_t Void_t4861ACF8F4594C3437BB48B6E56783494B843915__padding[1];
	};
};
struct Delegate_t  : public RuntimeObject
{
	intptr_t ___method_ptr;
	intptr_t ___invoke_impl;
	RuntimeObject* ___m_target;
	intptr_t ___method;
	intptr_t ___delegate_trampoline;
	intptr_t ___extra_arg;
	intptr_t ___method_code;
	intptr_t ___interp_method;
	intptr_t ___interp_invoke_impl;
	MethodInfo_t* ___method_info;
	MethodInfo_t* ___original_method_info;
	DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E* ___data;
	bool ___method_is_virtual;
};
struct Delegate_t_marshaled_pinvoke
{
	intptr_t ___method_ptr;
	intptr_t ___invoke_impl;
	Il2CppIUnknown* ___m_target;
	intptr_t ___method;
	intptr_t ___delegate_trampoline;
	intptr_t ___extra_arg;
	intptr_t ___method_code;
	intptr_t ___interp_method;
	intptr_t ___interp_invoke_impl;
	MethodInfo_t* ___method_info;
	MethodInfo_t* ___original_method_info;
	DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E* ___data;
	int32_t ___method_is_virtual;
};
struct Delegate_t_marshaled_com
{
	intptr_t ___method_ptr;
	intptr_t ___invoke_impl;
	Il2CppIUnknown* ___m_target;
	intptr_t ___method;
	intptr_t ___delegate_trampoline;
	intptr_t ___extra_arg;
	intptr_t ___method_code;
	intptr_t ___interp_method;
	intptr_t ___interp_invoke_impl;
	MethodInfo_t* ___method_info;
	MethodInfo_t* ___original_method_info;
	DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E* ___data;
	int32_t ___method_is_virtual;
};
struct TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0  : public RuntimeObject
{
	CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED ___m_defaultCancellationToken;
	TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___m_defaultScheduler;
	int32_t ___m_defaultCreationOptions;
	int32_t ___m_defaultContinuationOptions;
};
struct MulticastDelegate_t  : public Delegate_t
{
	DelegateU5BU5D_tC5AB7E8F745616680F337909D3A8E6C722CDF771* ___delegates;
};
struct MulticastDelegate_t_marshaled_pinvoke : public Delegate_t_marshaled_pinvoke
{
	Delegate_t_marshaled_pinvoke** ___delegates;
};
struct MulticastDelegate_t_marshaled_com : public Delegate_t_marshaled_com
{
	Delegate_t_marshaled_com** ___delegates;
};
struct Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87  : public MulticastDelegate_t
{
};
struct Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07  : public MulticastDelegate_t
{
};
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_StaticFields
{
	int32_t ___s_taskIdCounter;
	RuntimeObject* ___s_taskCompletionSentinel;
	bool ___s_asyncDebuggingEnabled;
	Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___s_taskCancelCallback;
	Func_1_tD59A12717D79BFB403BF973694B1BE5B85474BD1* ___s_createContingentProperties;
	TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* ___U3CFactoryU3Ek__BackingField;
	Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* ___U3CCompletedTaskU3Ek__BackingField;
	Predicate_1_t7F48518B008C1472339EEEBABA3DE203FE1F26ED* ___s_IsExceptionObservedByParentPredicate;
	ContextCallback_tE8AFBDBFCC040FDA8DA8C1EEFE9BD66B16BDA007* ___s_ecCallback;
	Predicate_1_t8342C85FF4E41CD1F7024AC0CDC3E5312A32CB12* ___s_IsTaskContinuationNullPredicate;
	Dictionary_2_t403063CE4960B4F46C688912237C6A27E550FF55* ___s_currentActiveTasks;
	RuntimeObject* ___s_activeTasksLock;
};
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_ThreadStaticFields
{
	Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* ___t_currentTask;
	StackGuard_tACE063A1B7374BDF4AD472DE4585D05AD8745352* ___t_stackGuard;
};
struct TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E_StaticFields
{
	TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___s_defaultTaskScheduler;
	int32_t ___s_taskSchedulerIdCounter;
	EventHandler_1_tE698654C3F437D97ABCCA3FD0AD8F86E776DC77A* ____unobservedTaskException;
	Lock_t529C04C831C120E5FFD6039EC3CB76F9956BCDD7* ____unobservedTaskExceptionLockObject;
};
struct UnityThreadUtils_tCC1D0915CC9C90AEB5B27F2A9D791544FAC0DEBA_StaticFields
{
	int32_t ___s_UnityThreadId;
	TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___U3CUnityThreadSchedulerU3Ek__BackingField;
};
struct Boolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22_StaticFields
{
	String_t* ___TrueString;
	String_t* ___FalseString;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_StaticFields
{
	Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___s_actionToActionObjShunt;
};
#ifdef __clang__
#pragma clang diagnostic pop
#endif


IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Action_1_Invoke_mF2422B2DD29F74CE66F791C3F68E288EC7C3DB9E_gshared_inline (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* __this, RuntimeObject* ___0_obj, const RuntimeMethod* method) ;

IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_inline (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED CancellationToken_get_None_mB0E2D3427C25F09ACEBB2D060F82088EEC00BA53 (const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_inline (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* TaskFactory_StartNew_m9A85CE0BA992F5B0735034FFF493F81E7D69C587 (TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* __this, Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED ___1_cancellationToken, int32_t ___2_creationOptions, TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___3_scheduler, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* TaskFactory_StartNew_m88C988599EC138D716C0822099C3E6DCC79CC4E8 (TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* __this, Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED ___2_cancellationToken, int32_t ___3_creationOptions, TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___4_scheduler, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool UnityThreadUtils_get_IsRunningOnUnityThread_m5FD8E9090E2A2EE035677BC109B12A234B91A1B4 (const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Action_Invoke_m7126A54DACA72B845424072887B5F3A51FC3808E_inline (Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A (Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Task_Wait_m33955515E36BF6598FCEDA841C8C75F716DE5A4E (Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* __this, const RuntimeMethod* method) ;
inline void Action_1_Invoke_mF2422B2DD29F74CE66F791C3F68E288EC7C3DB9E_inline (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* __this, RuntimeObject* ___0_obj, const RuntimeMethod* method)
{
	((  void (*) (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87*, RuntimeObject*, const RuntimeMethod*))Action_1_Invoke_mF2422B2DD29F74CE66F791C3F68E288EC7C3DB9E_gshared_inline)(__this, ___0_obj, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal_Send_m91B4D5F642779F7886B18FDBB6ACAAB3CAE65DB6 (Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal_Send_m701390E8B2BC62F04BFC284B5A6A60C3CA8278E9 (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2 (RuntimeObject* __this, const RuntimeMethod* method) ;
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A (Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_il2cpp_TypeInfo_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A_RuntimeMethod_var, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 0));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 1));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 2));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 3));
		il2cpp_codegen_runtime_class_init_inline(Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var);
		TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* L_0;
		L_0 = Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_inline(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 3));
		Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* L_1 = ___0_action;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 4));
		il2cpp_codegen_runtime_class_init_inline(CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_il2cpp_TypeInfo_var);
		CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED L_2;
		L_2 = CancellationToken_get_None_mB0E2D3427C25F09ACEBB2D060F82088EEC00BA53(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 4));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 5));
		TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* L_3;
		L_3 = UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_inline(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 5));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 6));
		NullCheck(L_0);
		Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* L_4;
		L_4 = TaskFactory_StartNew_m9A85CE0BA992F5B0735034FFF493F81E7D69C587(L_0, L_1, L_2, 0, L_3, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 6));
		return L_4;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_il2cpp_TypeInfo_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action), (&___1_state));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F_RuntimeMethod_var, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 7));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 8));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 9));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 10));
		il2cpp_codegen_runtime_class_init_inline(Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var);
		TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* L_0;
		L_0 = Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_inline(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 10));
		Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* L_1 = ___0_action;
		RuntimeObject* L_2 = ___1_state;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 11));
		il2cpp_codegen_runtime_class_init_inline(CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_il2cpp_TypeInfo_var);
		CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED L_3;
		L_3 = CancellationToken_get_None_mB0E2D3427C25F09ACEBB2D060F82088EEC00BA53(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 11));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 12));
		TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* L_4;
		L_4 = UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_inline(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 12));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 13));
		NullCheck(L_0);
		Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* L_5;
		L_5 = TaskFactory_StartNew_m88C988599EC138D716C0822099C3E6DCC79CC4E8(L_0, L_1, L_2, L_3, 0, L_4, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 13));
		return L_5;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal_Send_m91B4D5F642779F7886B18FDBB6ACAAB3CAE65DB6 (Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Send_m91B4D5F642779F7886B18FDBB6ACAAB3CAE65DB6_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Send_m91B4D5F642779F7886B18FDBB6ACAAB3CAE65DB6_RuntimeMethod_var, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 28));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 29));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 30));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 31));
		bool L_0;
		L_0 = UnityThreadUtils_get_IsRunningOnUnityThread_m5FD8E9090E2A2EE035677BC109B12A234B91A1B4(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 31));
		if (!L_0)
		{
			goto IL_000e;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 32));
		Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* L_1 = ___0_action;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 33));
		NullCheck(L_1);
		Action_Invoke_m7126A54DACA72B845424072887B5F3A51FC3808E_inline(L_1, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 33));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 34));
		return;
	}

IL_000e:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 35));
		Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* L_2 = ___0_action;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 36));
		Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* L_3;
		L_3 = UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A(L_2, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 36));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 37));
		NullCheck(L_3);
		Task_Wait_m33955515E36BF6598FCEDA841C8C75F716DE5A4E(L_3, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 37));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 38));
		return;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal_Send_m701390E8B2BC62F04BFC284B5A6A60C3CA8278E9 (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Send_m701390E8B2BC62F04BFC284B5A6A60C3CA8278E9_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action), (&___1_state));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Send_m701390E8B2BC62F04BFC284B5A6A60C3CA8278E9_RuntimeMethod_var, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 39));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 40));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 41));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 42));
		bool L_0;
		L_0 = UnityThreadUtils_get_IsRunningOnUnityThread_m5FD8E9090E2A2EE035677BC109B12A234B91A1B4(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 42));
		if (!L_0)
		{
			goto IL_000f;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 43));
		Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* L_1 = ___0_action;
		RuntimeObject* L_2 = ___1_state;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 44));
		NullCheck(L_1);
		Action_1_Invoke_mF2422B2DD29F74CE66F791C3F68E288EC7C3DB9E_inline(L_1, L_2, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 44));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 45));
		return;
	}

IL_000f:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 46));
		Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* L_3 = ___0_action;
		RuntimeObject* L_4 = ___1_state;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 47));
		Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* L_5;
		L_5 = UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F(L_3, L_4, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 47));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 48));
		NullCheck(L_5);
		Task_Wait_m33955515E36BF6598FCEDA841C8C75F716DE5A4E(L_5, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 48));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 49));
		return;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_get_IsRunningOnUnityThread_m264DB20EE6404E1C396E078FADE78F0C91CC7E1A (UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_get_IsRunningOnUnityThread_m264DB20EE6404E1C396E078FADE78F0C91CC7E1A_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC_0_0_0_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_get_IsRunningOnUnityThread_m264DB20EE6404E1C396E078FADE78F0C91CC7E1A_RuntimeMethod_var, methodExecutionContextThis, NULL, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 74));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 75));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 76));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 77));
		bool L_0;
		L_0 = UnityThreadUtils_get_IsRunningOnUnityThread_m5FD8E9090E2A2EE035677BC109B12A234B91A1B4(NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 77));
		return L_0;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_mB7F687F4632DE34A0AF82D911BD507987CD59356 (UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC* __this, Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_mB7F687F4632DE34A0AF82D911BD507987CD59356_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC_0_0_0_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_mB7F687F4632DE34A0AF82D911BD507987CD59356_RuntimeMethod_var, methodExecutionContextThis, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 78));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 79));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 80));
		Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* L_0 = ___0_action;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 81));
		Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* L_1;
		L_1 = UnityThreadUtilsInternal_PostAsync_m324667C9E5B9E25D01ED8F00E68330130F3B435A(L_0, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 81));
		return L_1;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_m2A06D795FE85F4D5B5E0492FF45E0BD3379B2F46 (UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC* __this, Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_m2A06D795FE85F4D5B5E0492FF45E0BD3379B2F46_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC_0_0_0_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action), (&___1_state));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_PostAsync_m2A06D795FE85F4D5B5E0492FF45E0BD3379B2F46_RuntimeMethod_var, methodExecutionContextThis, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 82));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 83));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 84));
		Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* L_0 = ___0_action;
		RuntimeObject* L_1 = ___1_state;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 85));
		Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* L_2;
		L_2 = UnityThreadUtilsInternal_PostAsync_mC858E8A5C829E4053E13566318F03866AA7A171F(L_0, L_1, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 85));
		return L_2;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m6A90E8351E6FD33374C3D7EAF7C7D74872E0A1B8 (UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC* __this, Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___0_action, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m6A90E8351E6FD33374C3D7EAF7C7D74872E0A1B8_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC_0_0_0_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m6A90E8351E6FD33374C3D7EAF7C7D74872E0A1B8_RuntimeMethod_var, methodExecutionContextThis, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 94));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 95));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 96));
		Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* L_0 = ___0_action;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 97));
		UnityThreadUtilsInternal_Send_m91B4D5F642779F7886B18FDBB6ACAAB3CAE65DB6(L_0, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 97));
		return;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m8918510A7586D876A98DC733B90FB534B228BE3F (UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC* __this, Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___0_action, RuntimeObject* ___1_state, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m8918510A7586D876A98DC733B90FB534B228BE3F_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC_0_0_0_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_action), (&___1_state));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal_Unity_Services_Core_Threading_Internal_IUnityThreadUtils_Send_m8918510A7586D876A98DC733B90FB534B228BE3F_RuntimeMethod_var, methodExecutionContextThis, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 98));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 99));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 100));
		Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* L_0 = ___0_action;
		RuntimeObject* L_1 = ___1_state;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 101));
		UnityThreadUtilsInternal_Send_m701390E8B2BC62F04BFC284B5A6A60C3CA8278E9(L_0, L_1, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core_Threading + 101));
		return;
	}
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityThreadUtilsInternal__ctor_m9430BA50989685AA40935124D40A44F29156A3A2 (UnityThreadUtilsInternal_t80A0011DD0CD9318DC38466ABEEAE4AD8B07B2AC* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtilsInternal__ctor_m9430BA50989685AA40935124D40A44F29156A3A2_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtilsInternal__ctor_m9430BA50989685AA40935124D40A44F29156A3A2_RuntimeMethod_var, NULL, NULL, NULL);
	CHECK_PAUSE_POINT;
	{
		Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2(__this, NULL);
		return;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_inline (const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, Task_get_Factory_m8272CF9106A72E5F0B8E8C6CEE025D748FBD6D11_RuntimeMethod_var, NULL, NULL, NULL);
	CHECK_PAUSE_POINT;
	{
		il2cpp_codegen_runtime_class_init_inline(Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var);
		TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* L_0 = ((Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_StaticFields*)il2cpp_codegen_static_fields_for(Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_il2cpp_TypeInfo_var))->___U3CFactoryU3Ek__BackingField;
		return L_0;
	}
}
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_inline (const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&UnityThreadUtils_tCC1D0915CC9C90AEB5B27F2A9D791544FAC0DEBA_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, UnityThreadUtils_get_UnityThreadScheduler_mE9C3F85F54EF3425CB76B8899D0F0BFBA705E3F2_RuntimeMethod_var, NULL, NULL, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core + 234));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Services_Core + 235));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Services_Core + 236));
		TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* L_0 = ((UnityThreadUtils_tCC1D0915CC9C90AEB5B27F2A9D791544FAC0DEBA_StaticFields*)il2cpp_codegen_static_fields_for(UnityThreadUtils_tCC1D0915CC9C90AEB5B27F2A9D791544FAC0DEBA_il2cpp_TypeInfo_var))->___U3CUnityThreadSchedulerU3Ek__BackingField;
		return L_0;
	}
}
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Action_Invoke_m7126A54DACA72B845424072887B5F3A51FC3808E_inline (Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* __this, const RuntimeMethod* method) 
{
	typedef void (*FunctionPointerType) (RuntimeObject*, const RuntimeMethod*);
	((FunctionPointerType)__this->___invoke_impl)((Il2CppObject*)__this->___method_code, reinterpret_cast<RuntimeMethod*>(__this->___method));
}
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Action_1_Invoke_mF2422B2DD29F74CE66F791C3F68E288EC7C3DB9E_gshared_inline (Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* __this, RuntimeObject* ___0_obj, const RuntimeMethod* method) 
{
	typedef void (*FunctionPointerType) (RuntimeObject*, RuntimeObject*, const RuntimeMethod*);
	((FunctionPointerType)__this->___invoke_impl)((Il2CppObject*)__this->___method_code, ___0_obj, reinterpret_cast<RuntimeMethod*>(__this->___method));
}
