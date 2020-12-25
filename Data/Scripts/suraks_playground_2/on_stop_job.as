#include "timed_execution/after_char_init_job.as"

funcdef void ON_STOP_CALLBACK(MovementObject@);

class OnStopJob : BasicJobInterface {
    protected int char_id;
    protected ON_STOP_CALLBACK @callback;
    protected vec3 last_pos;

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

        if(last_pos == char.position){
            return true;
        }else{
            last_pos = char.position;
            return false;
        }
    }

    bool IsRepeating(){
        return false;
    }
}
