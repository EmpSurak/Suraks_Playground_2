#include "object_locator/object_locator.as"
#include "timed_execution/timed_execution.as"
#include "timed_execution/repeating_delayed_job.as"

const float MPI = atan(1) * 4.0f;
const string _name_key = "Object name to circle";
const string _target_name_key = "Name";
const string _default_name = "Unknown";
const string _repeat_time_key = "Repeat time";
const float _default_repeat_time = 0.01f;
const string _radius_x_key = "Radius X";
const float _default_radius_x = 0.00f;
const string _radius_y_key = "Radius Y";
const float _default_radius_y = 0.00f;
const string _radius_z_key = "Radius Z";
const float _default_radius_z = 0.00f;
const string _round_increment_key = "Round increment";
const float _default_round_increment = 0.00f;
const string _start_pos_x_key = "Start Position X";
const string _start_pos_y_key = "Start Position Y";
const string _start_pos_z_key = "Start Position Z";
const string _reverse_x_key = "Reverse X";
const string _reverse_y_key = "Reverse Y";
const string _reverse_z_key = "Reverse Z";

string search_for_name;
ObjectLocator locator;
TimedExecution timer;

// FIXME: approach does not allow multiple circle hotspots at the same time for one object
float counter = 0.0f;

void Init(){}

void SetParameters(){
    params.AddString(_name_key, _default_name);
    params.AddString(_repeat_time_key, formatFloat(_default_repeat_time, '0', 2, 2));
    params.AddString(_radius_x_key, formatFloat(_default_radius_x, '0', 2, 2));
    params.AddString(_radius_y_key, formatFloat(_default_radius_y, '0', 2, 2));
    params.AddString(_radius_z_key, formatFloat(_default_radius_z, '0', 2, 2));
    params.AddString(_round_increment_key, formatFloat(_default_round_increment, '0', 2, 2));
    params.AddString(_reverse_x_key, "0");
    params.AddString(_reverse_y_key, "0");
    params.AddString(_reverse_z_key, "0");

    // Has to be global for the anonymous function.
    search_for_name = params.GetString(_name_key);
}

void HandleEvent(string event, MovementObject @mo){
    if(!mo.controlled){
        return;
    }
    if(event == "enter"){
        float repeat_time = _default_repeat_time;
        if(params.HasParam(_repeat_time_key)){
            repeat_time = params.GetFloat(_repeat_time_key);
        }
        timer.Add(RepeatingDelayedJob(repeat_time, function(){
            CircleObjects();
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

void CircleObjects(){
    if(!params.HasParam(_round_increment_key) || params.GetFloat(_round_increment_key) <= 0.0f){
        return;
    }
    counter += params.GetFloat(_round_increment_key);

    array<Object@> objects = GetObjects();
    for(uint i=0; i < objects.length(); ++i){
        Object @obj = objects[i];
        ScriptParams@ obj_params = obj.GetScriptParams();

        vec3 pos = obj.GetTranslation();
        obj_params.AddFloat(_start_pos_x_key, pos.x);
        obj_params.AddFloat(_start_pos_y_key, pos.y);
        obj_params.AddFloat(_start_pos_z_key, pos.z);

        if(params.HasParam(_radius_x_key) && params.GetFloat(_radius_x_key) > 0.0f){
            float reverser = 1;
            if(params.HasParam(_reverse_x_key) && params.GetString(_reverse_x_key) == "1"){
                reverser = -1;
            }
            pos.x = params.GetFloat(_radius_x_key) * sin(reverser * counter) + obj_params.GetFloat(_start_pos_x_key);
        }

        if(params.HasParam(_radius_y_key) && params.GetFloat(_radius_y_key) > 0.0f){
            float reverser = 1;
            if(params.HasParam(_reverse_y_key) && params.GetString(_reverse_y_key) == "1"){
                reverser = -1;
            }
            pos.y = params.GetFloat(_radius_y_key) * sin(reverser * counter) + obj_params.GetFloat(_start_pos_y_key);
        }

        if(params.HasParam(_radius_z_key) && params.GetFloat(_radius_z_key) > 0.0f){
            float reverser = 1;
            if(params.HasParam(_reverse_z_key) && params.GetString(_reverse_z_key) == "1"){
                reverser = -1;
            }
            pos.z = params.GetFloat(_radius_z_key) * cos(reverser * counter) + obj_params.GetFloat(_start_pos_z_key);
        }

        obj.SetTranslation(pos);
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

void PreScriptReload(){
    timer.DeleteAll();
}

void PostScriptReload(){
    Init();
}
