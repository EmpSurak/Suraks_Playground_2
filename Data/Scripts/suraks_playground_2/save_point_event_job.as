#include "timed_execution/level_event_job.as"

funcdef void SAFE_POINT_EVENT_CALLBACK(MovementObject@);

class SavePointEventJob : LevelEventJob {
    SAFE_POINT_EVENT_CALLBACK @sp_callback;

    SavePointEventJob(){}

    SavePointEventJob(SAFE_POINT_EVENT_CALLBACK @_callback){
        @sp_callback = @_callback;
    }

    void ExecuteEvent(array<string> _props){
        MovementObject @char = ReadCharacterID(atoi(_props[3]));
        sp_callback(char);
    }

    bool IsEvent(array<string> _event){
        if (_event[0] != "level_event")
            return false;
            
        if (_event[1] != "hotspot_announcer")
            return false;
            
        if (_event[2] != "save_point")
            return false;
            
        if (_event[4] != "enter" && _event[4] != "exit")
            return false;
    
        return true;
    }

    bool IsRepeating(){
        return true;
    }
}
