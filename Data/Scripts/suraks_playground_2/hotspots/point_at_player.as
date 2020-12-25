#include "object_locator/object_locator.as"
#include "timed_execution/timed_execution.as"
#include "timed_execution/after_init_job.as"
#include "timed_execution/simple_delayed_job.as"

const float MPI = atan(1) * 4.0f;
const string _name_key = "Object name to rotate";
const string _target_name_key = "Name";
const string _default_name = "Unknown";
const string _rotation_offset_key = "Rotation offset";
const float _default_rotation_offset = 90.0f;
const string _default_rotation_key = "Default rotation";
const string _no_reset_key = "Do not reset";
const string _reset_time_key = "Reset time";
const float _default_reset_time = 5.0f;

string search_for_name;
ObjectLocator locator;
TimedExecution timer;

void Init(){
    timer.Add(AfterInitJob(function(){
        SetDefaultRotation();
    }));
}

void SetParameters(){
    params.AddString(_name_key, _default_name);
    params.AddString(_rotation_offset_key, formatFloat(_default_rotation_offset, '0', 2, 2));
    params.AddString(_reset_time_key, formatFloat(_default_reset_time, '0', 2, 2));

    // Has to be global for the anonymous function.
    search_for_name = params.GetString(_name_key);
}

void HandleEvent(string event, MovementObject @mo){
    if(!mo.controlled){
        return;
    }
    if(event == "exit"){
        if(!params.HasParam(_no_reset_key)){
            float reset_time = 0.0f;
            if(params.HasParam(_reset_time_key)){
                reset_time = params.GetFloat(_reset_time_key);
            }
            timer.Add(SimpleDelayedJob(reset_time, function(){
                ResetObjectsRotation();
            }));
        }
    }
}

void Update(){
    if(EditorModeActive() || !ReadObjectFromID(hotspot.GetID()).GetEnabled()){
        return;
    }

    array<int> colliding_chars;
    level.GetCollidingObjects(hotspot.GetID(), colliding_chars);
    for(uint i = 0; i < colliding_chars.size(); i++){
        if(ReadObjectFromID(colliding_chars[i]).GetType() == _movement_object){
            MovementObject@ mo = ReadCharacterID(colliding_chars[i]);
            RotateObjectsRelativeToPlayer(mo);
        }
    }

    timer.Update();
}

void SetDefaultRotation(){
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

void ResetObjectsRotation(){
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

void RotateObjectsRelativeToPlayer(MovementObject @mo){
    array<Object@> objects = GetObjects();
    for(uint i=0; i < objects.length(); ++i){
        Object @obj = objects[i];
        vec3 obj_to_char = obj.GetTranslation() - mo.position;
        obj_to_char = normalize(obj_to_char);
        float rot = atan2(obj_to_char.x, obj_to_char.z)*180.0f/MPI - params.GetFloat(_rotation_offset_key);
        obj.SetRotation(quaternion(vec4(0, 1, 0, rot*MPI/180.0f)));
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

void PreScriptReload(){
    timer.DeleteAll();
}

void PostScriptReload(){
    Init();
}
