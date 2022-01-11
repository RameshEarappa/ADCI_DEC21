tableextension 60004 Venor extends Vendor
{
    fields
    {
        field(60000; "Vendor Type"; Option)
        {
            OptionMembers = "Business Vendor","Internal Vendor"," ";
            DataClassification = ToBeClassified;
        }
    }
}
