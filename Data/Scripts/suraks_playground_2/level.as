#include "timed_execution/timed_execution.as"

TimedExecution timer;

void Init(string str){}

void Update(int is_paused){
    timer.Update();
}

void DrawGUI(){}

void Draw(){}

bool HasFocus(){
    return false;
}
