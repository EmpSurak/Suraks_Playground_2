#include "timed_execution/timed_execution.as"
#include "suraks_playground_2/save_point_event_job.as"
#include "suraks_playground_2/char_death_event_job.as"
#include "suraks_playground_2/after_ragdoll_job.as"
#include "timed_execution/on_input_pressed_job.as"

TimedExecution timer;
dictionary positions;

void Init(){
    timer.Add(SavePointEventJob(function(_char){
        string id = formatInt(_char.GetID());
        positions[id] = _char.position;
    }));

    timer.Add(CharDeathEventJob(function(_char){
        _char.QueueScriptMessage("full_revive");

        timer.Add(AfterRagdollJob(_char, function(_char){
            PlaySound("Data/Sounds/ambient/amb_canyon_hawk_1.wav");

            string id = formatInt(_char.GetID());
            if(positions.exists(id)){
                _char.position = vec3(positions[id]);
            }
        }));
    }));

    timer.Add(OnInputPressedJob(0, "l", function(){
        PlaySound("Data/Sounds/ambient/amb_canyon_hawk_1.wav");

        array<string> pos_keys = positions.getKeys();
        for(uint i = 0; i < pos_keys.length(); i++){
            MovementObject @_char = ReadCharacterID(atoi(pos_keys[i]));
            _char.position = vec3(positions[pos_keys[i]]);
        }

        return true;
    }));

    level.ReceiveLevelEvents(hotspot.GetID());
}

void Dispose(){
    level.StopReceivingLevelEvents(hotspot.GetID());
}

void Update(){
    timer.Update();
}

void ReceiveMessage(string msg){
    timer.AddEvent(msg);
}

void PreScriptReload(){
    timer.DeleteAll();
}

void PostScriptReload(){
    Init();
}
