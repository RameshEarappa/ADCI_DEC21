pageextension 60004 "Purchase Order" extends "Purchase Order"
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
