package com.furkanages.elements

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar

class ElementOfDayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
        // Schedule daily updates at midnight
        scheduleDailyUpdate(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(ComponentName(context, ElementOfDayWidgetProvider::class.java))
                onUpdate(context, manager, ids)
            }
            "com.furkanages.elements.DAILY_UPDATE" -> {
                // Handle daily update at midnight
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(ComponentName(context, ElementOfDayWidgetProvider::class.java))
                onUpdate(context, manager, ids)
                // Schedule next day's update
                scheduleDailyUpdate(context)
            }
            Intent.ACTION_BOOT_COMPLETED -> {
                // Reschedule daily updates after device reboot
                scheduleDailyUpdate(context)
            }
        }
    }

    private fun colorForCategory(category: String?): Int {
        val c = category?.lowercase()?.trim() ?: return Color.parseColor("#1C2A3E")
        return when (c) {
            "alkali metal" -> Color.parseColor("#14B8A6") // turquoise
            "alkaline earth metal" -> Color.parseColor("#FACC15") // yellow
            "transition metal" -> Color.parseColor("#8B5CF6") // purple
            "post-transition metal" -> Color.parseColor("#6B7280") // steel blue-ish
            "metalloid" -> Color.parseColor("#F5CBA7") // skin color-ish
            "reactive nonmetal" -> Color.parseColor("#EF4444") // powder red-ish
            "noble gas" -> Color.parseColor("#22C55E") // glow green-ish
            "halogen" -> Color.parseColor("#A3E635") // light green-ish
            "lanthanide" -> Color.parseColor("#0891B2") // dark turquoise-ish
            "actinide" -> Color.parseColor("#EC4899") // pink-ish
            else -> Color.parseColor("#1C2A3E")
        }
    }

    private fun darken(color: Int, factor: Float = 0.85f): Int {
        val r = (Color.red(color) * factor).toInt().coerceIn(0, 255)
        val g = (Color.green(color) * factor).toInt().coerceIn(0, 255)
        val b = (Color.blue(color) * factor).toInt().coerceIn(0, 255)
        return Color.rgb(r, g, b)
    }

    private fun cardBgResForCategory(category: String?): Int {
        val c = category?.lowercase()?.trim()
        return when (c) {
            "alkali metal" -> R.drawable.bg_card_alkali_metal
            "alkaline earth metal" -> R.drawable.bg_card_alkaline_earth_metal
            "transition metal" -> R.drawable.bg_card_transition_metal
            "post-transition metal" -> R.drawable.bg_card_post_transition_metal
            "metalloid" -> R.drawable.bg_card_metalloid
            "reactive nonmetal" -> R.drawable.bg_card_reactive_nonmetal
            "noble gas" -> R.drawable.bg_card_noble_gas
            "halogen" -> R.drawable.bg_card_halogen
            "lanthanide" -> R.drawable.bg_card_lanthanide
            "actinide" -> R.drawable.bg_card_actinide
            else -> R.drawable.bg_card_default
        }
    }

    private fun badgeBgResForCategory(category: String?): Int {
        val c = category?.lowercase()?.trim()
        return when (c) {
            "alkali metal" -> R.drawable.bg_badge_alkali_metal
            "alkaline earth metal" -> R.drawable.bg_badge_alkaline_earth_metal
            "transition metal" -> R.drawable.bg_badge_transition_metal
            "post-transition metal" -> R.drawable.bg_badge_post_transition_metal
            "metalloid" -> R.drawable.bg_badge_metalloid
            "reactive nonmetal" -> R.drawable.bg_badge_reactive_nonmetal
            "noble gas" -> R.drawable.bg_badge_noble_gas
            "halogen" -> R.drawable.bg_badge_halogen
            "lanthanide" -> R.drawable.bg_badge_lanthanide
            "actinide" -> R.drawable.bg_badge_actinide
            else -> R.drawable.bg_badge_default
        }
    }

    private fun localizedCategory(categoryRaw: String?, locale: java.util.Locale): String? {
        val c = categoryRaw?.lowercase()?.trim() ?: return null
        if (locale.language != "tr") return categoryRaw
        return when (c) {
            "alkali metal" -> "Alkali Metal"
            "alkaline earth metal" -> "Toprak Alkali Metal"
            "transition metal" -> "Geçiş Metalleri"
            "post-transition metal" -> "Zayıf Metaller"
            "metalloid" -> "Yarı Metal"
            "reactive nonmetal" -> "Reaktif Ametal"
            "noble gas" -> "Soygaz"
            "halogen" -> "Halojen"
            "lanthanide" -> "Lantanit"
            "actinide" -> "Aktinit"
            else -> categoryRaw
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = HomeWidgetPlugin.getData(context)
        val symbol = prefs.getString("symbol", "?")
        val enName = prefs.getString("enName", "Element")
        val trName = prefs.getString("trName", enName)
        val number = prefs.getString("number", "-")
        val categoryRaw = prefs.getString("category", null)
        val atomicWeight = prefs.getString("atomicWeight", null)

        val locale = context.resources.configuration.locales[0]
        val date = java.text.DateFormat.getDateInstance(java.text.DateFormat.MEDIUM, locale)
            .format(java.util.Date())
        val category = localizedCategory(categoryRaw, locale)

        val views = RemoteViews(context.packageName, R.layout.element_of_day_widget).apply {
            // Set element information
            setTextViewText(R.id.txtTitle, context.getString(R.string.widget_title_element_of_day))
            setTextViewText(R.id.txtSymbol, symbol)
            setTextViewText(R.id.txtName, trName ?: enName)
            setTextViewText(R.id.txtNumber, number)
            setTextViewText(R.id.txtCategory, category ?: "")

            // Background and colors
            setInt(R.id.card, "setBackgroundResource", R.drawable.bg_widget_atom)
            val accent = Color.parseColor("#FFFFFF")
            setTextViewText(R.id.txtDate, date)
            setTextColor(R.id.txtTitle, accent)
            setTextColor(R.id.txtSymbol, accent)
            setTextColor(R.id.txtName, accent)
            setTextColor(R.id.txtNumber, accent)
            setTextColor(R.id.txtCategory, accent)
            setTextColor(R.id.txtDate, accent)
            setTextColor(R.id.txtAtomicWeight, accent)

            val aw = if (atomicWeight.isNullOrBlank()) "" else context.getString(R.string.widget_atomic_weight, atomicWeight)
            setTextViewText(R.id.txtAtomicWeight, aw)

            // Set click intents to open the app
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.card, pendingIntent)
            setOnClickPendingIntent(R.id.txtTitle, pendingIntent)
            setOnClickPendingIntent(R.id.txtSymbol, pendingIntent)
            setOnClickPendingIntent(R.id.txtName, pendingIntent)
            setOnClickPendingIntent(R.id.btnOpen, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    private fun scheduleDailyUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ElementOfDayWidgetProvider::class.java).apply {
            action = "com.furkanages.elements.DAILY_UPDATE"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Cancel existing alarm
        alarmManager.cancel(pendingIntent)
        
        // Set alarm for next midnight
        val calendar = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_MONTH, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        
        try {
            // Use setInexactRepeating for daily widget updates - no special permissions required
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setInexactRepeating(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    AlarmManager.INTERVAL_DAY,
                    pendingIntent
                )
            } else {
                alarmManager.setRepeating(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    AlarmManager.INTERVAL_DAY,
                    pendingIntent
                )
            }
        } catch (e: SecurityException) {
            // Handle permission denied gracefully
            android.util.Log.w("ElementOfDayWidget", "Cannot schedule alarm: ${e.message}")
        }
    }
}
