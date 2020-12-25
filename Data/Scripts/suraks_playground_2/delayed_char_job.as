#include "timed_execution/timer_job_interface.as"

funcdef void TIMED_CHAR_CALLBACK(MovementObject@);

class DelayedCharJob : TimerJobInterface {
    protected float wait;
    protected int char_id;
    protected TIMED_CHAR_CALLBACK @callback;
    protected float started;

    DelayedCharJob(){}

    DelayedCharJob(float _wait, int _char_id, TIMED_CHAR_CALLBACK @_callback){
        wait = _wait;
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

    bool IsExpired(float time){
        return time > GetEndTime();
    }

    bool IsRepeating(){
        return false;
    }

    void SetStarted(float time){
        started = time;
    }

    private float GetEndTime(){
        return started+wait;
    }
}
