//
//  ExportView.swift
//  Course Builder
//
//  Created by Cynthia Z France on 4/23/23.
//

import SwiftUI

struct ExportView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var schedule: Schedule
    @State var pdf_exp: Bool = false
    @State var image_exp: Bool = false
    
    var body: some View {
        List {
            HStack {
                //MARK: cancel takes the user back to the previous page
                Spacer()
                Button("Cancel") {
                    self.mode.wrappedValue.dismiss()
                }
                .padding()
            }
            .listRowSeparator(.hidden)
            
            HStack(alignment: .center) {
                Spacer()
                Text("Export Schedule")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Spacer()
            }
            .listRowSeparator(.hidden)
            
            HStack {
                Spacer()
                ZStack {
                    //MARK: preview the image/pdf that will be exported
                    Rectangle()
                        .fill(.white)
                        .frame(width: 620, height: 870)
                        .shadow(radius: 5, x: 0, y: 5)
                    PDFView(schedule: schedule)
                }
                Spacer()
            }
            .listRowSeparator(.hidden)
            
            HStack(alignment: .center) {
                //MARK: user chooses to either export as pdf to Coredata, or as image to the photos app
                Spacer()
                Button("export as PDF to CoreData") {
                    pdf_exp.toggle()
                    exportPDF()
                }
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $pdf_exp){
                    self.mode.wrappedValue.dismiss()
                    return Alert(title: Text("Export Successful"), message: Text("exported to CoreData"), dismissButton: .default(Text("ok"), action: {self.mode.wrappedValue.dismiss()}))
                }
                
                Spacer()
                
                Button("export to Photos") {
                    image_exp.toggle()
                    saveImage()
                }
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $image_exp){
                    return Alert(title: Text("Export Successful"), message: Text("exported to photos"), dismissButton: .default(Text("ok"), action: {self.mode.wrappedValue.dismiss()}))
                }
                Spacer()
            }
            .padding(.bottom)
            .listRowSeparator(.hidden)
        }
        .ignoresSafeArea()
    }
    
    //MARK: get the PDFView (what will be saved)
    func getView() -> some View {
        PDFView(schedule: schedule)
    }
    
    //MARK: saves schedule as pdf to disk
    @MainActor
    func exportPDF() {
        //MARK: create the path and renders the PDF
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let renderedUrl = documentDirectory.appending(path: "schedule.pdf")
        if let consumer = CGDataConsumer(url: renderedUrl as CFURL),
           let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) {
            let renderer = ImageRenderer(content: getView())
            
            renderer.render { size, renderer in
                //MARK: creates and saves the pdf to the specified path
                let options: [CFString: Any] = [
                    kCGPDFContextMediaBox: CGRect(origin: .zero, size: size)
                ]
                pdfContext.beginPDFPage(options as CFDictionary)
                renderer(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
            }
        }
        print("Saving PDF to \(renderedUrl.path())")
    }
    
    //MARK: saves schedule as image to photos app
    @MainActor
    func saveImage() {
        //MARK: renders image
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let renderedUrl = documentDirectory.appending(path: "schedule.pdf")
        if let consumer = CGDataConsumer(url: renderedUrl as CFURL),
           let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) {
            let renderer = ImageRenderer(content: getView())
            
            //MARK: save image to photos album
            if let image = renderer.uiImage {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
        }
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = Schedule(name: "sched", desc: "", program: .Software)
        ExportView(schedule: schedule)
    }
}
