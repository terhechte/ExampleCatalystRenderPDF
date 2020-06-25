//
//  ViewController.swift
//  PDFExample
//
//  Created by terhechte on 25.06.20.
//

import UIKit
import SwiftUI
import PDFKit

class InnerState {
    var action: (() -> Void)?
}

struct ExampleView: View {
    var state: InnerState
    var body: some View {
        HStack {
            VStack {
                Text("Hello")
                Text("Beautiful")
                Text("World").font(.headline)
            }
            VStack {
                Image(systemName: "house")
                HStack {
                    Text("First")
                    Text("Second")
                }.background(Color.blue)
                Button("Render PDf") {
                    self.state.action?()
                }
            }
        }
    }
}

class ViewController: UIHostingController<ExampleView> {
    
    let state = InnerState()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(rootView: ExampleView(state: state))
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(rootView: ExampleView(state: state))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state.action = {
            self.renderPDF()
        }
    }
    
    func renderPDF() {
        let renderer = UIGraphicsPDFRenderer(bounds: view.bounds)
        let url = temporaryPath(for: "example_file.pdf")
        try! renderer.writePDF(to: url) { (context) in
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        }
        
        present(PDFViewController(url), animated: true)
    }
    
    public func temporaryPath(for filename: String) -> URL {
        let dir = NSTemporaryDirectory()
        let fullPath = "\(dir)/\(filename)"
        let outputURL = URL(fileURLWithPath: fullPath)
        return outputURL
    }
}

// This exists to display the PDF
final class PDFViewController: UIViewController {
    private let pdfURL: URL
    init(_ url: URL) {
        self.pdfURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pdfDocument = PDFDocument(url: pdfURL) {
            let pdfView = PDFView()
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument
            view.addSubview(pdfView)
            pdfView.frame = view.bounds
        }
    }
}

