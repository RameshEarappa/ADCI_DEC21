pageextension 60003 "Posted Purchase Receipt" extends "Posted Purchase Receipt"
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
