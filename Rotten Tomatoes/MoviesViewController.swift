//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Dinh Thi Minh on 11/10/15.
//  Copyright © 2015 Dinh Thi Minh. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var movies: [NSDictionary]?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = NSURL(string: "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214")!
        
        let request = NSURLRequest(URL: url)
        CozyLoadingActivity.show("Loading...", disableUI: true)

        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
        
            guard error == nil else  {
                CozyLoadingActivity.hide(success: false, animated: true)
                print("error loading from URL", error!)
               
                UIView.animateWithDuration(5,
                    animations:
                    {
                        self.label.alpha = 1
                        self.label.text = "Network Error!"
                    })
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
                self.movies = json["movies"] as? [NSDictionary]
                
                self.tableView.reloadData()
                CozyLoadingActivity.hide(success: true, animated: true)
              
            } catch {
                CozyLoadingActivity.hide(success: false, animated: true)
                print("json error")
            }
        })
        tableView.dataSource = self
        tableView.delegate = self
        
        //Pull to refresh tableView
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(refreshControl)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if let movies = movies {
           return movies.count
            
        } else {
           return 0
           
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String

        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String )!
        cell.posterView.setImageWithURL(url)
        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }    // MARK: - Navigation
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        
        // Get the new view controller using segue.destinationViewController.
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        
        // Pass the selected object to the new view controller.
        movieDetailsViewController.movie = movie
        
    }

}
