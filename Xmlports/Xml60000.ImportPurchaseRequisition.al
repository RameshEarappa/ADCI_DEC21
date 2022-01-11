xmlport 60000 "Import Purchase Requisition"
{
    Caption = 'Import Purchase Requisition';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;
    FieldSeparator = ',';
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("PurchaseRequisitionLine"; "Purchase Requisition Line")
            {
                fieldelement(Type; PurchaseRequisitionLine."Type")
                {
                }
                fieldelement(No; PurchaseRequisitionLine."No.")
                {
                }
                textelement(Description)
                {
                }
                fieldelement(Quantity; PurchaseRequisitionLine.Quantity)
                {
                }
                textelement(UnitofMeasureCode)
                {
                }
                fieldelement(Remarks; PurchaseRequisitionLine.Remarks)
                {
                }
                textelement(DirectUnitCost)
                {
                    MinOccurs = Zero;
                }

                trigger OnAfterInitRecord()
                begin
                    if Pagecaption = true then begin
                        Pagecaption := false;
                        RowNumber += 1;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    RecLines: Record "Purchase Requisition Line";
                    testdecimal: Decimal;
                begin
                    PurchaseRequisitionLine."Document No." := DocumentNo;
                    LineNumber += 10000;
                    PurchaseRequisitionLine.ValidateNumber();
                    PurchaseRequisitionLine."Line No." := LineNumber;
                    if Description <> '' then
                        PurchaseRequisitionLine.Description := Description;
                    if UnitofMeasureCode <> '' then
                        PurchaseRequisitionLine.Validate("Unit of Measure Code", UnitofMeasureCode);
                    Clear(testdecimal);
                    if DirectUnitCost <> '' then begin
                        Evaluate(testdecimal, DirectUnitCost);
                        PurchaseRequisitionLine.Validate("Direct Unit Cost", testdecimal);
                    end;
                    nRecNum += 1;
                    dlgProgress.UPDATE(1, nRecNum);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        Pagecaption := true;
        RowNumber := 0;
        dlgProgress.OPEN(tcProgress);
        LineNumber := GetLastLineNumber();
    end;

    trigger OnPostXmlPort()
    begin
        dlgProgress.CLOSE;
    end;

    procedure SetDOcumentNumber(DocumentNumberp: code[20])
    begin
        Clear(DocumentNo);
        DocumentNo := DocumentNumberp;
    end;

    local procedure GetLastLineNumber(): Integer
    var
        RecLines: Record "Purchase Requisition Line";
    begin
        Clear(RecLines);
        RecLines.SetCurrentKey("Document No.", "Line No.");
        RecLines.SetRange("Document No.", DocumentNo);
        if RecLines.FindLast() then
            exit(RecLines."Line No.")
        else
            exit(0);
    end;

    var
        Pagecaption: Boolean;
        RowNumber: Integer;
        DocumentNo: code[20];
        dlgProgress: Dialog;
        nRecNum: Integer;
        LineNumber: Integer;
        tcProgress: Label 'Uploading Records #1';
}
