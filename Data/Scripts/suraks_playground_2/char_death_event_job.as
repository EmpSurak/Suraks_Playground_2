#include "timed_execution/level_event_job.as"

funcdef void CHAR_DEATH_EVENT_CALLBACK(MovementObject@);

class CharDeathEventJob : LevelEventJob {
    CHAR_DEATH_EVENT_CALLBACK @sp_callback;

    CharDeathEventJob(){}

    CharDeathEventJob(CHAR_DEATH_EVENT_CALLBACK @_callback){
        @sp_callback = @_callback;
    }

    void ExecuteEvent(array<string> _props){
        MovementObject @char = ReadCharacterID(atoi(_props[2]));
        sp_callback(char);
    }

    bool IsEvent(array<string> _event){
        if (_event[0] != "level_event")
            return false;

        if (_event[1] != "character_died" && _event[1] != "character_knocked_out")
            return false;
    
        return true;
    }

    bool IsRepeating(){
        return true;
    }
}
