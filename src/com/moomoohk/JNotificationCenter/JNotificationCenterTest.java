package com.moomoohk.JNotificationCenter;

import com.moomoohk.JNotificationCenter.notifications.SimpleNotification;

public class JNotificationCenterTest
{
	public static void main(String[] args)
	{
		JNotificationCenter.load();

		String title = "title";
		String message = "message";
		String subtitle = "subtitle";
		String sender = "com.apple.safari";
		OSXSoundEffect sound = OSXSoundEffect.FUNK;
		SimpleNotification n = new SimpleNotification(title, message, subtitle, sender, sound);
		n.show();
	}
}
