#include "timed_execution/timed_execution.as"
#include "suraks_playground_2/save_point_event_job.as"
#include "suraks_playground_2/char_death_event_job.as"
#include "suraks_playground_2/after_ragdoll_job.as"

TimedExecution timer;

dictionary positions;
dictionary velocities;

void Init(){
    timer.Add(SavePointEventJob(function(_char){
        string id = formatInt(_char.GetID());
        positions[id] = _char.position;
        velocities[id] = _char.velocity;
    }));

    timer.Add(CharDeathEventJob(function(_char){
        _char.QueueScriptMessage("full_revive");

        timer.Add(AfterRagdollJob(_char, function(_char){
            string id = formatInt(_char.GetID());
            if(positions.exists(id)){
                _char.position = vec3(positions[id]);
            }
            if(velocities.exists(id)){
                _char.velocity = vec3(velocities[id]);
            }
        }));
    }));

    level.ReceiveLevelEvents(hotspot.GetID());
}

void Dispose() {
    level.StopReceivingLevelEvents(hotspot.GetID());
}

void Update(){
    timer.Update();
}

void ReceiveMessage(string msg){
    timer.AddEvent(msg);
}
