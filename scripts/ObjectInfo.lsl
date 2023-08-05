// Simple object info script used in the SL GeoVisLab 

integer channel = 0;
string infotxt = "... info text ...";

default
{
    touch_start(integer total_number)
    {
        string msg = "\n";
        msg += infotxt;
        llDialog(llDetectedKey(0), msg, [], channel);
    }     
}
