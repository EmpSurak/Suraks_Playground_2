#include "object_locator/object_locator.as"
#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/repeating_delayed_job.as"

const float MPI = 3.14159265359;
const string _name_key = "Object name to rotate";
const string _target_name_key = "Name";
const string _default_name = "Unknown";
const string _rotation_offset_key = "Rotation offset";
const float _default_rotation_offset = 90.0f;
const string _default_rotation_key = "Default rotation";
const string _repeat_time_key = "Repeat time";
const float _default_repeat_time = 0.01f;
const string _rotation_axis_key = "Rotation axis";
const string _default_rotation_axis = "x";
const string _round_increment_key = "Round increment";
const float _default_round_increment = 1.00f;

string search_for_name;
ObjectLocator locator;
TimedExecution timer;
float counter = 0;

void Init() {  
    timer.Add(AfterInitJob(function(){
        SetDefaultRotation();
    }));
}

void SetParameters() {
    params.AddString(_name_key, _default_name);
    params.AddFloat(_rotation_offset_key, _default_rotation_offset);
    params.AddFloat(_repeat_time_key, _default_repeat_time);
    params.AddString(_rotation_axis_key, _default_rotation_axis);
    
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
    if(EditorModeActive() || !ReadObjectFromID(hotspot.GetID()).GetEnabled()){
        return;
    }
    
    timer.Update();
}

void SetDefaultRotation() {
    array<Object@> objects = GetDefaultlessObjects();
    for(uint i=0; i < objects.length(); ++i){
        Object @obj = objects[i];
        ScriptParams@ obj_params = obj.GetScriptParams();
        
        quaternion rot = obj.GetRotation();
        obj_params.AddFloat(_default_rotation_key + " X", rot.x);
        obj_params.AddFloat(_default_rotation_key + " Y", rot.y);
        obj_params.AddFloat(_default_rotation_key + " Z", rot.z);
        obj_params.AddFloat(_default_rotation_key + " W", rot.w);
    }
}

void ResetObjectsRotation() {
    array<Object@> objects = GetObjects();
    for(uint i=0; i < objects.length(); ++i){
        Object @obj = objects[i];
        ScriptParams@ obj_params = obj.GetScriptParams();
        
        obj.SetRotation(quaternion(
            obj_params.GetFloat(_default_rotation_key + " X"),
            obj_params.GetFloat(_default_rotation_key + " Y"),
            obj_params.GetFloat(_default_rotation_key + " Z"),
            obj_params.GetFloat(_default_rotation_key + " W")
        ));
    }
}

void RotateObjects(){
    float round_increment = _default_round_increment;
    if(params.HasParam(_round_increment_key)){
        round_increment = params.GetFloat(_round_increment_key);
    }
    counter = (counter + round_increment) % 360;

    array<Object@> objects = GetObjects();
    for(uint i=0; i < objects.length(); ++i){
        Object @obj = objects[i];

        string rotation_axis = _default_rotation_axis;
        if(params.HasParam(_rotation_axis_key)){
            rotation_axis = params.GetString(_rotation_axis_key);
        }

        if(rotation_axis == "x"){
            obj.SetRotation(quaternion(vec4(0, 1, 0, counter*MPI/180.0f)));
        }else if(rotation_axis == "y"){
            obj.SetRotation(quaternion(vec4(0, 0, 1, counter*MPI/180.0f)));
        }
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

array<Object@> GetDefaultlessObjects(){
    return locator.LocateByScriptParams(function(_params){
        if(!_params.HasParam(_target_name_key)){
            return false;
        }
        if(search_for_name != _params.GetString(_target_name_key)){
            return false;
        }
        return !_params.HasParam(_default_rotation_key + " X");
    });
}
