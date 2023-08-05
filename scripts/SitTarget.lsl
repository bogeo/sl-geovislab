// Script allowing to sit on an object

default
{
    state_entry()
    {
        // Set sit target, otherwise this will not work 
        llSitTarget(<0.4, 0.0, 0.6>, ZERO_ROTATION);
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        { 
            key av = llAvatarOnSitTarget();
            if (av) 
            {
                // av is evaluated as true, if key is valid and not NULL_KEY
                llSay(0, "Hello " + llKey2Name(av) + ", thank you for sitting down");
            }
        }
    }
}