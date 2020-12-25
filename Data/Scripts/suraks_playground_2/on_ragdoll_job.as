#include "timed_execution/after_char_init_job.as"

funcdef void ON_RAGDOLL_CALLBACK(MovementObject@);

class OnRagdollJob : BasicJobInterface {
    protected int char_id;
    protected ON_RAGDOLL_CALLBACK @callback;

    OnRagdollJob(){}

    OnRagdollJob(int _char_id, ON_RAGDOLL_CALLBACK @_callback){
        char_id = _char_id;
        @callback = @_callback;
    }

    void ExecuteExpired(){
        if(!MovementObjectExists(char_id)){
            return;
        }
        MovementObject@ char = ReadCharacterID(char_id);
        callback(char);
    }

    bool IsExpired(){
        if(!MovementObjectExists(char_id)){
            return true;
        }
        MovementObject@ char = ReadCharacterID(char_id);
        return char.GetIntVar("state") == 4; // _ragdoll_state
    }

    bool IsRepeating(){
        return false;
    }
}
