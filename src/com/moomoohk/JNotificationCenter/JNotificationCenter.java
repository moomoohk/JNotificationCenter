package com.moomoohk.JNotificationCenter;

public class JNotificationCenter
{
	private static boolean loaded = false;

	public static void load()
	{
		try
		{
			System.loadLibrary("JNotificationCenter");
			loaded = true;
		}
		catch (UnsatisfiedLinkError err)
		{
			throw new RuntimeException(err);
		}
	}

	public static boolean isLoaded()
	{
		return loaded;
	}
}
