#include "timed_execution/after_char_init_job.as"

funcdef void AFTER_RAGDOLL_CALLBACK(MovementObject@);

class AfterRagdollJob : AfterCharInitJob {
    MovementObject @char;
    AFTER_RAGDOLL_CALLBACK @new_callback;

    AfterRagdollJob(){}

    AfterRagdollJob(MovementObject @_char, AFTER_RAGDOLL_CALLBACK @_callback){
        @char = @_char;
        @new_callback = @_callback;
    }

    void ExecuteExpired(){
        new_callback(char);
    }

    bool IsExpired(float time){
        return char.GetIntVar("state") != 4; // _ragdoll_state
    }
}
