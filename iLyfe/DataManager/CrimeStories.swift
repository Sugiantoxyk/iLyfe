//
//  CrimeStories.swift
//  iLyfe
//
//  Created by JT on 11/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class CrimeStories: NSObject {
    static func stories() -> ([Crime]){
        return [
            Crime("START PARASITE RACE", "https://us.123rf.com/450wm/vectorshowstudio/vectorshowstudio1708/vectorshowstudio170800076/83310491-stock-vector-blood-or-paint-splatters-splash-spot-red-stain-blot-patch-liquid-texture-drop-grunge-abstract-dirty-.jpg?ver=6", "None... None left... They all had turned... The world is now a graveyard.")
            /*Crime("The lost boy", "https://us.123rf.com/450wm/vetalgard/vetalgard1503/vetalgard150300066/38777475-stock-vector-femida-lady-justice-graphic-vector-illustration.jpg?ver=6", "It all started with him, the boy with that mask on..."),
            Crime("Hangman", "https://us.123rf.com/450wm/ratoca/ratoca1905/ratoca190500318/123595960-stock-vector-design-of-hanged-man-in-tree.jpg?ver=6", "There's no solution, you cannot defeat them. It's either you die or ... you die.")*/
        ]
    }
    
    static func instruct() -> String{
        return "Users will be given time to reach each checkpoint. Each checkpoint contains a mission. Once you reach that certain checkpoint, you'll be given the mission with a time limit for you to complete that mission. \n\nThe mission given is to kill the parasites before they attack you. You'll be given 50 ammo to shoot at the parasites.  \n\nWhen run out of ammo, you won't be able to shoot anymore. Every 20 seconds of time, there will be an ammo booster appearing, shoot it to gain more ammos. \n\nWhen time is up, the race will continue. \n\nKill more parasites to unlock more achievements. Complete race on time and unlock another achievement. Have fun racing!"
    }
}
