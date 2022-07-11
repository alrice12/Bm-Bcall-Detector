import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

<ty:Result>
{
    for $doc in collection("Detections")/ty:Detections
      let $eff := $doc/Effort
      let $node := base-uri($doc)
      let $baddetections := 
        for $det at $pos in $doc/OnEffort/Detection
        return
      	   if ($det/Start < $eff/Start or $det/End > $eff/End) then
	      <OutsideEffort>
	       <Entry>{$pos}</Entry>
	       {$det/Start}
	       {$det/End}
	      </OutsideEffort>
           else
              if (fn:exists($det/End) and $det/End < $det/Start) then
	        <EndBeforeStart>
		   <Entry>{$pos}</Entry>
	           {$det/Start}
	           {$det/End}
	        </EndBeforeStart>
	   else ()

      return if ($baddetections != ()) then
         <Detections>
	    <doc>{$node}</doc>
            {$eff/Start}
	    {$eff/End}
	    {badddetections}
	 </Detections>
      else ()
}
</ty:Result>
