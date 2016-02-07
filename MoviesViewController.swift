//
//  MoviesViewController.swift
//  CodePath_Flicks
//
//  Created by Tim Kaing on 1/25/16.
//  Copyright © 2016 Daisukiyo. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var moviesearchBar: UISearchBar!
    
    var filteredData: [String]!
    var data: [String] = []
    
    var movies: [NSDictionary]?
    //added "?" to make it optional therefore making the app safer and less likely to crash
    
    var endpoint: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        self.navigationItem.titleView = searchBar
        */
        
        
        errorView.hidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        moviesearchBar.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        
        filteredData = data

        networkRequest()
       
        
        // hey man hows it goin
        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        networkRequest()
        refreshControl.endRefreshing()
    }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            
                            for var i = 0; i < self.movies!.count; i++ {
                                let movie = self.movies![i]
                                self.data.append(movie["title"] as? String ?? "")
                            }
                            
                            self.filteredData = self.data
                            
                            self.tableView.reloadData()
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                }
                else{
                    self.errorView.hidden = false
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        if let movies = movies{
//            return filteredData.count
//        }
//        else{
//            return 0
//        }
        
        return filteredData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String ?? ""
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if(cell.selected){
            cell.backgroundColor = UIColor.redColor()
        }else{
            cell.backgroundColor = UIColor.blackColor()
        }
        
        if let posterpath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterpath)
            let imageRequest = NSURLRequest(URL: imageUrl!)
            
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

        }

        
        cell.titleLabel.text = filteredData[indexPath.row]
        cell.overviewLabel.text = overview
        
        
        //by adding an exclamation I am positive that there is something there
        
        
        print("row \(indexPath.row)")
        return cell
    }
   
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        // will tim ever find these comments
    }
    

}
