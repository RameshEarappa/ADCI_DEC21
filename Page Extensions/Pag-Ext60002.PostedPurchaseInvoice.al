pageextension 60002 "Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field("Purchase Requisition No."; Rec."Purchase Requisition No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}
