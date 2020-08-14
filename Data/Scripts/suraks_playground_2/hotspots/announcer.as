const string _event_name = "hotspot_announcer";
const string _name_key = "Announcement name";
const string _default_name = "";

void Init(){}

void SetParameters(){
    params.AddString(_name_key, _default_name);
}

void HandleEvent(string event, MovementObject @mo){
    level.SendMessage(_event_name + " " + params.GetString(_name_key) + " " + mo.GetID() + " " + event);
}

void Update(){}
