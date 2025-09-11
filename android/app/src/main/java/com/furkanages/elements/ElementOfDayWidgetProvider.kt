package com.furkanages.elements

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ElementOfDayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ElementOfDayWidgetProvider::class.java))
            onUpdate(context, manager, ids)
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

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = HomeWidgetPlugin.getData(context)
        val symbol = prefs.getString("symbol", "?")
        val enName = prefs.getString("enName", "Element")
        val number = prefs.getString("number", "-")
        val category = prefs.getString("category", null)

        val baseColor = colorForCategory(category)
        val badgeBg = darken(baseColor, 0.7f)

        val views = RemoteViews(context.packageName, R.layout.element_of_day_widget).apply {
            setTextViewText(R.id.txtSymbol, symbol)
            setTextViewText(R.id.txtName, enName)
            setTextViewText(R.id.txtNumber, "#$number")
            setTextViewText(R.id.txtCategory, category ?: "")

            // Dynamic backgrounds matching app's UI
            setInt(R.id.card, "setBackgroundColor", baseColor)
            setInt(R.id.txtNumber, "setBackgroundColor", badgeBg)
            setTextColor(R.id.txtNumber, Color.WHITE)
            setTextColor(R.id.txtSymbol, Color.WHITE)

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            setOnClickPendingIntent(R.id.imgChem, pendingIntent)
            setOnClickPendingIntent(R.id.imgOpenApp, pendingIntent)
            setOnClickPendingIntent(R.id.card, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
