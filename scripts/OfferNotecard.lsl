// Offer a notecard to the user

default
{
    touch_start(integer total_number)
    {
        string notecard = llGetInventoryName(INVENTORY_NOTECARD, 0);
        key touchingAvatar = llDetectedKey(0);
        llSay(0, "Feel free to take a notecard!");
        llGiveInventory(touchingAvatar, notecard);
    }
}
