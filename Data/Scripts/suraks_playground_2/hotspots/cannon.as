#include "object_locator/object_locator.as"
#include "timed_execution/timed_execution.as"
#include "timed_execution/after_char_init_job.as"
#include "suraks_playground_2/on_ragdoll_job.as"
#include "suraks_playground_2/on_stop_job.as"
#include "suraks_playground_2/delayed_char_job.as"

const string _target_name_key = "Target Name";
const string _push_force_key = "Push Force";
const float _push_force_default = 75.0f;

TimedExecution timer;
ObjectLocator locator;

void Init(){}

void SetParameters(){
    params.AddString(_target_name_key, "");
    params.AddFloat(_push_force_key, _push_force_default);
}

void HandleEvent(string event, MovementObject @mo){
    if(!mo.controlled){
        return;
    }

    if(event == "enter"){
        int projectile_id = CreateObject("Data/Objects/characters/rats/rat_actor.xml", true);
        MovementObject@ projectile_char = ReadCharacterID(projectile_id);

        Object@ projectile_obj = ReadObjectFromID(projectile_char.GetID());
        Object@ target_obj = locator.LocateByName(params.GetString(_target_name_key));

        if(target_obj is null){
            @target_obj = ReadObjectFromID(hotspot.GetID());
        }

        projectile_obj.SetTranslation(target_obj.GetTranslation());
        projectile_obj.SetRotation(target_obj.GetRotation());

        timer.Add(AfterCharInitJob(projectile_char.GetID(), function(projectile_char){
            timer.Add(DelayedCharJob(0.1f, projectile_char.GetID(), function(projectile_char){
                projectile_char.Execute("GoLimp();");
                projectile_char.Execute("permanent_health = 0.0f;");
            }));            

            timer.Add(OnRagdollJob(projectile_char.GetID(), function(projectile_char){
                Object@ target_obj = locator.LocateByName(params.GetString(_target_name_key));

                if(target_obj is null){
                    @target_obj = ReadObjectFromID(hotspot.GetID());
                }

                const float _push_force_mult = params.GetFloat(_push_force_key);
                vec3 push_force;
                vec3 direction = target_obj.GetRotation() * vec3(0,0,-1);
                push_force.x -= direction.x;
                push_force.z -= direction.z;
                push_force *= _push_force_mult;

                RiggedObject@ obj_rigged = projectile_char.rigged_object();
                obj_rigged.ApplyForceToRagdoll(
                    push_force * 500.0f,
                    obj_rigged.skeleton().GetCenterOfMass()
                );

                timer.Add(DelayedCharJob(1.0f, projectile_char.GetID(), function(projectile_char){
                    timer.Add(OnStopJob(projectile_char.GetID(), function(projectile_char){
                        QueueDeleteObjectID(projectile_char.GetID());
                    }));
                }));
            }));
        }));
    }
}

void Update(){
    timer.Update();
}

void PreScriptReload(){
    timer.DeleteAll();
}

void PostScriptReload(){
    Init();
}
