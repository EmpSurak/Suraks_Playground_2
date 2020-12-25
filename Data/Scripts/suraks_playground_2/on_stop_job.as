#include "timed_execution/after_char_init_job.as"

funcdef void ON_STOP_CALLBACK(MovementObject@);

class OnStopJob : BasicJobInterface {
    protected int char_id;
    protected ON_STOP_CALLBACK @callback;

    OnStopJob(){}

    OnStopJob(int _char_id, ON_STOP_CALLBACK @_callback){
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
        return char.velocity.x <= 0.0f && char.velocity.y <= 0.0f && char.velocity.z <= 0.0f;
    }

    bool IsRepeating(){
        return false;
    }
}
