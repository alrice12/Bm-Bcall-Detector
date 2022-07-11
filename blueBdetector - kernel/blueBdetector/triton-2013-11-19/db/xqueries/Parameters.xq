import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

<ty:Result>
{
    let $human := lib:completename2tsn("Homo sapiens")
    for $doc in collection("Detections")/ty:Detections
      where $doc/DataSource/Site = "G2" and
      $doc/DataSource/Project = "SOCAL"

      return
        for $det in $doc/OnEffort/Detection
            where $det/Parameters/Subtype = "Echosounder"
            return $det
}
</ty:Result>
