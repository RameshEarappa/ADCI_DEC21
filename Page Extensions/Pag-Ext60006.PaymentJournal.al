pageextension 60006 "Payment Journal" extends "Payment Journal"
{
    actions
    {
        modify(Post)
        {
            trigger OnBeforeAction()
            var
                Utility: Codeunit "Requisition Utility";
            begin
                Utility.ValidateVendorPaymentApplication(Rec);
            end;
        }
        modify("Post and &Print")
        {
            trigger OnBeforeAction()
            var
                Utility: Codeunit "Requisition Utility";
            begin
                Utility.ValidateVendorPaymentApplication(Rec);
            end;
        }
    }
}
