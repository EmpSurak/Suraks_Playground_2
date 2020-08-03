#include "object_locator/object_locator.as"
#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/repeating_delayed_job.as"

const float MPI = 3.14159265359;
const string _name_key = "Object name to rotate";
const string _target_name_key = "Name";
const string _default_name = "Unknown";
const string _default_rotation_key = "Default rotation";
const string _repeat_time_key = "Repeat time";
const float _default_repeat_time = 0.01f;
const string _round_increment_x_key = "Round increment X";
const float _default_round_increment_x = 0.00f;
const string _round_increment_y_key = "Round increment Y";
const float _default_round_increment_y = 0.00f;
const string _reverse_x_key = "Reverse X";
const string _reverse_y_key = "Reverse Y";

string search_for_name;
ObjectLocator locator;
TimedExecution timer;

void Init(){}

void SetParameters(){
    params.AddString(_name_key, _default_name);
    params.AddString(_repeat_time_key, formatFloat(_default_repeat_time, '0', 2, 2));
    params.AddString(_round_increment_x_key, formatFloat(_default_round_increment_x, '0', 2, 2));
    params.AddString(_round_increment_y_key, formatFloat(_default_round_increment_y, '0', 2, 2));
    params.AddString(_reverse_x_key, "0");
    params.AddString(_reverse_y_key, "0");
    
    // Has to be global for the anonymous function.
    search_for_name = params.GetString(_name_key);
}

void HandleEvent(string event, MovementObject @mo){
    if(event == "enter"){
        float repeat_time = _default_repeat_time;
        if(params.HasParam(_repeat_time_key)){
            repeat_time = params.GetFloat(_repeat_time_key);
        }
        timer.Add(RepeatingDelayedJob(repeat_time, function(){
            RotateObjects();
            return true;
        }));
    }else if(event == "exit"){
        timer.DeleteAll();
    }
}

void Update(){
    if(!ReadObjectFromID(hotspot.GetID()).GetEnabled()){
        return;
    }
    
    timer.Update();
}

void RotateObjects(){
    array<Object@> objects = GetObjects();
    for(uint i=0; i < objects.length(); ++i){
        Object @obj = objects[i];
        quaternion rot = obj.GetRotation();

        if(params.HasParam(_round_increment_x_key) && params.GetFloat(_round_increment_x_key) > 0.0f){
            float value = params.GetFloat(_round_increment_x_key)*MPI/180.0f;
            if(params.HasParam(_reverse_x_key) && params.GetString(_reverse_x_key) == "1"){
                value *= -1;
            }
            rot = quaternion(vec4(0, 0, 1, value)) * rot;
        }
        
        if(params.HasParam(_round_increment_y_key) && params.GetFloat(_round_increment_y_key) > 0.0f){
            float value = params.GetFloat(_round_increment_y_key)*MPI/180.0f;
            if(params.HasParam(_reverse_y_key) && params.GetString(_reverse_y_key) == "1"){
                value *= -1;
            }
            rot = quaternion(vec4(0, 1, 0, value)) * rot;
        }
        
        obj.SetRotation(rot);
    }
}

array<Object@> GetObjects(){
    return locator.LocateByScriptParams(function(_params){
        if(!_params.HasParam(_target_name_key)){
            return false;
        }
        return (search_for_name == _params.GetString(_target_name_key));
    });
}
