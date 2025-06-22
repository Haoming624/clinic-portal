module ApplicationHelper
    def status_badge_color(status)
        case status
        when 'active' then 'success'
        when 'discharged' then 'warning'
        when 'deceased' then 'danger'
        else 'secondary'
        end
    end
end
