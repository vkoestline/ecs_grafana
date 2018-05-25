# --------------------------------------                                       
# Create record in public DNS zone
# --------------------------------------                                       
resource "aws_route53_record" "grafana_public_dns" {                            
  zone_id = "${var.public_zone_id}"                                            
  name    = "${var.prefix}-grafana.${var.domain_name}.${var.tl_domain}"                                    
  type    = "A"                                                                
                                                                               
  alias {
    name                   = "${aws_alb.web.dns_name}"        
    zone_id                = "${aws_alb.web.zone_id}"
    evaluate_target_health = true                                              
  }
} 

