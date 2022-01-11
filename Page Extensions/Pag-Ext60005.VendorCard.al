pageextension 60005 "Vendor Card" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field("Vendor Type"; Rec."Vendor Type")
            {
                ApplicationArea = ALl;
            }
        }
    }
}
