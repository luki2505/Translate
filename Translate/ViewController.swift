//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sourceLanguage: UITextField!
    @IBOutlet weak var destinationLanguage: UITextField!
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var translateButton: UIButton!
    
    let pickerViewSource: UIPickerView = UIPickerView()
    let pickerViewDestination : UIPickerView = UIPickerView()
    var languages: [(key: String, text: String)] = [("en", "English"), ("fr", "French"), ("ga", "Gaelic"), ("de", "German"), ("tk", "Turkish")]
    let textToTranslateDefault = "<Text to Translate>"
    let translatedTextDefault = "<Translated Text>"
    
    //var data = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add "Done" key to keyboard
        self.addDoneButtonOnKeyboard()
        
        // Navigation Controller
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.19, green:0.29, blue:0.39, alpha:1.00)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        
        // Keyboard Dismissal
        self.hideKeyboardWhenTappedAround()
        
        // Setup TextViews
        self.textToTranslate.delegate = self
        self.translatedText.delegate = self
        
        // Setup PickerViews
        self.pickerViewSource.dataSource = self
        self.pickerViewSource.delegate = self
        self.sourceLanguage.inputView = self.pickerViewSource
        self.pickerViewDestination.dataSource = self
        self.pickerViewDestination.delegate = self
        self.destinationLanguage.inputView = self.pickerViewDestination
        self.sourceLanguage.text = languages[0].text
        self.destinationLanguage.text = languages[1].text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func translate(_ sender: AnyObject) {
        let sourceLangCode = getLanguageCode(language: sourceLanguage.text!)
        let destinationLangCode = getLanguageCode(language: destinationLanguage.text!)
        
        if sourceLangCode != nil && destinationLanguage != nil && sourceLangCode != destinationLangCode {
            let str = textToTranslate.text
            let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            let langStr = (sourceLangCode! + "|" + destinationLangCode!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
            
            var request = URLRequest(url: URL(string: urlStr)!)
            request.httpMethod = "POST"
            let session = URLSession.shared
            
            translateButton.isHidden = true
            indicatorView.isHidden = false
            indicatorView.startAnimating()
            
            var result = "<Translation Error>"
            
            session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.sync(execute: {
                    self.indicatorView.stopAnimating()
                    self.translateButton.isHidden = false
                })
                
                if error != nil {
                    print(error)
                } else {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        let responseData = parsedData["responseData"] as! [String:Any]
                        let translation = responseData["translatedText"] as! String
                        result = translation
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
                DispatchQueue.main.sync(execute: {
                    self.translatedText.textColor = UIColor.black
                    self.translatedText.text = result
                })
            }.resume()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.characters.count == 0 {
            if textView.tag == 8 {
                textView.text = textToTranslateDefault
            } else if textView.tag == 9 {
                textView.text = translatedTextDefault
            }
            textView.textColor = UIColor.lightGray
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewSource {
            sourceLanguage.text = languages[row].text
        } else if pickerView == pickerViewDestination {
            destinationLanguage.text = languages[row].text
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].text
    }
    
    func getLanguageCode(language: String) -> String? {
        for lang in self.languages {
            if lang.text == language {
                return lang.key
            }
        }
        return nil
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.textToTranslate.inputAccessoryView = doneToolbar
        self.translatedText.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction()
    {
        self.textToTranslate.resignFirstResponder()
        self.translatedText.resignFirstResponder()
    }
    
}

